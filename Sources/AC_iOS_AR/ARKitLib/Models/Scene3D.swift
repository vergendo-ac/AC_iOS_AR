//
//  Scene3D.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 15/04/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import SwiftyJSON
import ARKit

typealias ARFNodeDict = [String: [SCNNode]]
typealias ARFNodeAction = (item: SCNNode, action: SCNAction)

class Scene3D: ARFNode {
    
    private(set) var reconstructionId: Int?
    var srvCamera: ServerCamera?
    private(set) var nodes: [Node3D]?
    var stickersData: [StickerModels.StickerData] = []
    private(set) var unitsPerMeter: Float = 1
    
    private let syncRoot: NSRecursiveLock = NSRecursiveLock()
    static var anchorId: Int = 0
    
    let sticker: StickerService = StickerService.sharedInstance
    
    private var allNodes: [SCNNode] = []
    private var arkitView: ARSCNView?
    
    private(set) var anchors: [(anchor: ARAnchor, node: SCNNode)] = []
    private(set) var mainNode: Node3D?
    private(set) var arfNodes: ARFNodeDict = [:]
    private var prevArfNodes: ARFNodeDict = [:]
    private var edgeWidth = CGFloat(0.01)
    let animationDuration: TimeInterval = 0.5
    
    var arObjectsEnabled = false {
        didSet {
            for node in allNodes {
                node.isHidden = !arObjectsEnabled
            }
        }
    }
    
    /*var arAnimatedObjectsEnabled = false {
        didSet {
            for node in animatedNodes {
                node.isHidden = !arAnimatedObjectsEnabled
            }
        }
    }*/

    override init() {
        self.nodes = []
        self.stickersData = []
        super.init()
    }
    
    init(reconstructionId: Int?, nodes: [Node3D], srvCamera: ServerCamera, stickersData: [StickerModels.StickerData], unitsPerMeter: Float = 1) {
        self.reconstructionId = reconstructionId
        self.nodes = nodes
        self.srvCamera = srvCamera
        self.stickersData = stickersData
        self.unitsPerMeter = unitsPerMeter
        super.init()
    }
    
    init?(json: JSON) {
        self.nodes = []
        self.stickersData = []
        super.init()
        
        for item in json["scene"].array ?? [] {
            if let dict = item.dictionary {
                if let data = dict["node"] {
                    self.nodes!.append(Node3D(json: data))
                } else if let cameraData = dict["camera"] {
                    self.srvCamera = ServerCamera(json: cameraData)
                } else if let value = dict["units_per_meter"]?.float {
                    self.unitsPerMeter = value
                }
            }
        }
        
        //TODO: stickerData - should be dictionary [Hash:StickerOptions]
        self.stickersData = self.sticker.parseStickersInfo(json["objects_info"]) ?? []
        if self.stickersData.count == 0 { return nil }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clear(arkitView: ARSCNView? = nil) {
        
        /*for node in self.animatedNodes {
            node.removeFromParentNode()
        }*/

        for node in allNodes {
            node.removeFromParentNode()
        }

        
        if self.parent != nil {
            self.removeFromParentNode()
        }

        anchors = []
        mainNode = nil
        arfNodes = [:]
        allNodes = []
        //animatedNodes = []
        removeAllActions()
    }
    
    var serverScale: Double? {
        return unitsPerMeter > 0 ? 1.0/Double(unitsPerMeter) : nil
    }
    
    private func drawNode(points: [SCNVector3], stickerIndex: Int) -> [SCNNode]? {
        guard let arkitView = self.arkitView else {
            return nil
        }
        
        var center = SCNVector3()
        var nodes: [SCNNode] = []
        
        // draw sphere sticker
        for (idx, pt) in points.enumerated() {
            center += pt
            let apt = ARFSphereNode(radius: 0.02)
            let id = self.nodes![stickerIndex].id.hashValue
            apt.name = "\(id):\(idx)"
            apt.position = pt
            apt.isHidden = true
            arkitView.scene.rootNode.addChildNode(apt)
            nodes.append(apt)
            allNodes.append(apt)
        }
        
        //draw central node
            
        if points.count > 2,
            let usdzName = UserDefaults.current3DSticker,
            let arFun = UserDefaults.arFun, arFun,
            let triples = Scene3D.sortRectNodes(arkitView: arkitView, items: nodes) {
            
            //prepare orientation
            let centralPoint = center / points.count
            let sortedNodes = triples.map { $0.node }
            
            let a = sortedNodes[1].position - sortedNodes[0].position
            let b = sortedNodes[3].position - sortedNodes[0].position
            
            let width = sortedNodes[0].position.distance(to: sortedNodes[1].position)
            let height = sortedNodes[0].position.distance(to: sortedNodes[3].position)
            
            var normal = SCNVector3.vecmul(a: b, b: a)
            normal.normalize()
            
            let worldOrientation: simd_quatf = simd_quatf(from: simd_float3(0, 0, 1), to: simd_float3(normal))
            
            if let showArCreature = UserDefaults.arCreatures, showArCreature {
                let centerNode = ARFPlaneNode(width: CGFloat(width), height: CGFloat(height), name: usdzName)
                centerNode.simdWorldOrientation = worldOrientation
                centerNode.setValue(normal, forKey: "normalVector")
                
                centerNode.isHidden = !arObjectsEnabled
                centerNode.position = centralPoint
                
                arkitView.scene.rootNode.addChildNode(centerNode)
                allNodes.append(centerNode)
            } else if let arfUSDZNode = ARFUSDZNode(name: usdzName, radius: 0.2) as? ARFUSDZNode, let centerNode = arfUSDZNode.usdzNode {
                
                centerNode.simdWorldOrientation = worldOrientation
                centerNode.setValue(normal, forKey: "normalVector")
                
                centerNode.isHidden = !arObjectsEnabled
                centerNode.position = centralPoint
                arfUSDZNode.framePoints = points
                arkitView.scene.rootNode.addChildNode(centerNode)
                allNodes.append(centerNode)
            }

        }
        
        return nodes
    }
    
    func drawEdges() {
        
        guard let arkitView = self.arkitView else {
            return
        }
        
        // remove edges
        
        for node in allNodes.filter({$0 is ARFLineNode}) {
            node.removeFromParentNode()
        }
        
        allNodes = allNodes.filter({!($0 is ARFLineNode)})
        
        for (_, nodes) in arfNodes {
            
            guard let triples = Scene3D.sortRectNodes(arkitView: arkitView, items: nodes) else {
                return
            }
            
            let items = triples.map({$0.node})
            
            for (index, node) in items.enumerated() {
                let from = SCNVector3()
                var to = node.convertPosition(items[0].worldPosition, from: nil)
                if index < items.count - 1 {
                    to = node.convertPosition(items[index+1].worldPosition, from: nil)
                }
                
                let line = ARFLineNode(from: from, to: to, width: edgeWidth)
                node.addChildNode(line)
                allNodes.append(line)
            }
        }
    }
    
    func restoreScene(transformAB: double4x4, arkitView: ARSCNView, isEnabled: Bool) -> Bool {
        clear()
        self.arkitView = arkitView
        
        for (index, node) in (nodes ?? []).enumerated() {
            var points: [SCNVector3] = []
            for pt in node.points {
                let tp = transformAB*simd_double4(simd_double3(pt), 1.0)
                let p = SCNVector3(Float(tp.x), Float(tp.y), Float(tp.z))
                points.append(p)
            }
            
            // draw node
            let elems = self.drawNode(points: points, stickerIndex: index)
            
            // sort nodes
            guard let triples = Scene3D.sortRectNodes(arkitView: arkitView, items: elems ?? []) else {
                clear()
                return false
            }
            
            arfNodes[node.id] = triples.map({$0.node})
        }
        
        self.arObjectsEnabled = isEnabled
        //self.arAnimatedObjectsEnabled = !(UserDefaults.current3DSticker?.isEmpty ?? true)
        return true
    }
    
    func animateRestoreScene(actions: [ARFNodeAction], completion: @escaping () -> ()) {
        var counter = actions.count
        if counter > 0 {
            print("[animation] start animation")
            for elem in actions {
                elem.item.runAction(elem.action) { [weak self] in
                    guard let `self` = self else {
                        print("[animation] silf is nil")
                        return
                    }
                    self.syncRoot.lock()
                    
                    counter -= 1
                    if counter <= 0 {
                        self.syncRoot.unlock()
                        print("[animation] stop animation")
                        completion()
                    } else {
                        self.syncRoot.unlock()
                    }
                }
            }
        } else {
            completion()
        }
    }
    
    func prepareActions(prevScene: Scene3D, duration: TimeInterval? = nil) -> [ARFNodeAction]? {
        var result: [(item: SCNNode, action: SCNAction)] = []
        
        for (sid, items) in self.arfNodes {
            if let lastItems = prevScene.arfNodes[sid] {
                for item in items {
                    for lastItem in lastItems {
                        if item.name == lastItem.name {
                            let action = SCNAction.move(to: item.position, duration: duration ?? animationDuration)
                            item.worldPosition = lastItem.worldPosition
                            result.append((item, action))
                            
                            print("[animation] add action")
                        }
                    }
                }
            }
        }
        
        return result.count > 0 ? result : nil
    }
    
    class func sortRectNodes(arkitView: ARSCNView, items: [SCNNode]) -> [(pt: simd_float2, node: SCNNode, angle: Float)]? {
        guard items.count == 4 else {
            return nil
        }
        
        var points: [(pt: simd_float2, node: SCNNode)] = []
        for item in items {
            let pt = arkitView.projectPoint(item.worldPosition)
            points.append((simd_float2(pt.x, pt.y), item))
        }
        return clockwiseRectNodesSort(items: points)
    }
}
