//
//  ArCameraContext.swift
//  Developer
//
//  Created by Andrei Okoneshnikov on 10/07/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import ARKit

typealias PixelBufferWithPose = (id: String, image: CVPixelBuffer, cameraPose: simd_float4x4)

class ArCameraContext {
    
    enum AnchorMode: Int {
        case off = 0
        case points = 1
        case image = 2
        case sticker = 3
        case allStickers = 4
    }
    
    enum ScaleType {
        // user arkit to calculate scale
        case arkit(value: Double)
        // fetch from server
        case server(value: Double)
        // use 2 camera pose to calculate scale
        case usePoses(value: Double)
        case `default`(value: Double)
        case none
        
        var value: Double? {
            switch self {
                case .none:
                    return nil
            case .arkit(let val), .usePoses(let val), .server(let val), .default(let val):
                    return val
            }
        }
        
        var isLocal: Bool {
            switch self {
            case .usePoses, .arkit:
                return true
            default:
                return false
            }
        }
    }
    
    enum ScaleCalculationType {
        case arkit
        case server
        case poses
        case combine
        case none
        
        var isArkitEnabled: Bool {
            switch self {
            case .combine, .arkit:
                return true
            default:
                return false
            }
        }
    }
    
    static let scaleStepLimit = 10
    let lengthLimit = 0.3
   
    private(set) var cameraPoses: [(id: String, pose: simd_float4x4)] = []
    private var abTransforms: [simd_double4x4] = []
    private(set) var lastScale: ScaleType = .none
    private(set) var scaleCalculationType: ScaleCalculationType = .combine
    
    private(set) var posePixelBuffer: PixelBufferWithPose?
    
    private(set) var scenes: [Scene3D] = []
    private(set) var currentScene: Scene3D?
    private(set) var mainNode: Node3D?
    private(set) var arkitView: ARSCNView?
    private(set) var anchorNode: SCNNode?
    private(set) var arPlaneMaxDistance = 5.0
    private(set) var animationDuration: TimeInterval = 1.5
    private(set) var anchorMode: AnchorMode = .points
    private(set) var arHitTestResult: ARHitTestResult.ResultType = .existingPlaneUsingExtent
    
    let physicalWidthLimit: Float = 25
    let minPatchScreeSizeLimit: Float = 25
    let imageAnchorPointLimit: Float = 100
    
    init() {
        
    }
    
    var isAutoScale: Bool {
        return UserDefaults.arCameraAutoScale ?? false
    }
    
    var timerValue: TimeInterval {
        return TimeInterval(UserDefaults.arCameraTimerValue ?? 4)
    }
    
    func setArPlaneMaxDistance(_ value: Double) {
        arPlaneMaxDistance = value
    }
    
    func setScaleCalculationType(_ type: ScaleCalculationType) {
        scaleCalculationType = type
    }
    
    func setAnimationDuration(_ duration: TimeInterval) {
        animationDuration = duration
    }
    
    func setAnchorMode(_ mode: AnchorMode) {
        anchorMode = mode
    }
    
    func setMainNode(_ mainNode: Node3D) {
        self.mainNode = mainNode
    }
    
    func setArHitTestResult(_ resultType: ARHitTestResult.ResultType) {
        arHitTestResult = resultType
    }
    
    func put(pose: simd_float4x4, id: String? = nil) -> ArCameraContext {
        self.cameraPoses.append((id ?? UUID().uuidString, pose))
        return self
    }
    
    func put(scene: Scene3D) -> ArCameraContext {
        scenes.append(scene)
        mainNode = nil
        anchorNode = nil
        return self
    }
    
    func put(arkitView: ARSCNView) -> ArCameraContext {
        self.arkitView = arkitView
        return self
    }
    
    func put(posePixelBuffer: PixelBufferWithPose?) -> ArCameraContext {
        self.posePixelBuffer = posePixelBuffer
        return self
    }
    
    func clear() {
        cameraPoses = []
        scenes = []
        lastScale = .none
        mainNode = nil
        anchorNode = nil
        posePixelBuffer = nil
        print("[context] clear context")
    }
    
    func clearLast() {
        if cameraPoses.count > 0 {
            cameraPoses.remove(at: cameraPoses.count-1)
        }
    }
    
    private func clearArkitScene() {
        if let childs = arkitView?.scene.rootNode.childNodes {
            for child in childs {
                if child is ARFNode {
                    child.removeFromParentNode()
                }
            }
        }
        
        // remove anchors
        for anchor in arkitView?.session.currentFrame?.anchors ?? [] {
            if !(anchor is ArCameraPoseAnchor) {
                arkitView?.session.remove(anchor: anchor)
            }
        }
    }
    
    var lastPose: simd_float4x4? {
        return cameraPoses.last?.pose
    }
    
    /* Update pose by id
     */
    func updatePose(id: String, pose: simd_float4x4) -> Bool {
        if let index = cameraPoses.firstIndex(where: {$0.id == id}) {
            cameraPoses[index] = (id, pose)
            return true
        }
        return false
    }
    
    var count: Int {
        return scenes.count
    }
    
    private func calculateSceneTransform(nodes: [SCNNode]) -> float4x4? {
        guard nodes.count > 2 else {
            return nil
        }
        
        let points: [simd_float3] = [nodes[1].simdWorldPosition, nodes[2].simdWorldPosition, nodes[0].simdWorldPosition]
        return calculateStickerTransform(points: points)
    }
    
    /* Calculate scale between arkit scene and server scene
     step - step between first camera pose and second camera pose that used for calculation.
     */
    func calculateScale(step: Int = 1, limit: Int = ArCameraContext.scaleStepLimit) -> Double? {
        if scenes.count > step, scenes.count == cameraPoses.count, step < limit {
            let index = cameraPoses.count - 1
            let prevIndex = index - step
            
            let tf_ca_a_1 = cameraPoses[prevIndex].pose
            let tf_ca_a_2 = cameraPoses[index].pose
            
            let v_1_a = simd_double3(tf_ca_a_1.position)
            let v_2_a = simd_double3(tf_ca_a_2.position)
            let distance = length(v_1_a - v_2_a)
            
            print("[scale] srv distance:\(distance), step:\(step), scenes count:\(scenes.count)")
            
            if distance < lengthLimit {
                // if distance between poses < limit try use previous pose
                return calculateScale(step: step+1)
            }
            
            guard let camera1 = scenes[prevIndex].srvCamera, let camera = scenes[index].srvCamera else { return nil
            }
            
            let v_1_b = simd_double3(camera1.position)
            let v_2_b = simd_double3(camera.position)
            
            if length(v_1_b - v_2_b) < 0.001 {
                return nil
            }
            
            let ss = length(v_1_a - v_2_a)/length(v_1_b - v_2_b)
            let result = ss > 0.01 ? ss : nil
            
            print("[scale] srv scale:\(result ?? -1.0)")
            
            return result
        }
        
        return nil
    }
    
    private func getScale(from scene: Scene3D) -> ScaleType {
        if scene.serverScale != nil {
            return .server(value: scene.serverScale!)
        } else {
            return .default(value: 1.0)
        }
    }
    
    private func calculateABTransform(cameraTransform: double4x4, updateScale: Bool) -> double4x4? {
        guard let scene = scenes.last/*, cameraPoses.count == scenes.count*/ else {
            return nil
        }
        
        guard let camQuat = scene.srvCamera?.orientation else {
            return nil
        }
        
        if updateScale {
            var newScale: Double?
            
            if scaleCalculationType == .combine || scaleCalculationType == .poses {
                newScale = calculateScale()
            }
        
            if newScale == nil && !lastScale.isLocal {
                lastScale = getScale(from: scene)
            } else if newScale != nil {
                lastScale = .usePoses(value: newScale!)
            }
        } else {
            switch lastScale {
                case .none:
                    lastScale = getScale(from: scene)
                default:
                    break
            }
        }
        
        let tf_b_cb = double4x4(rotation: double3x3(camQuat), position: simd_double3(scene.srvCamera!.position))
        let tf_b_a = srvToArkitTransform(arkit: cameraTransform, server: tf_b_cb, scale: lastScale.value!)
        abTransforms.append(tf_b_a)
        return tf_b_a
    }

    func showLastScene(updateScale: Bool, isEnabled: Bool, animated: Bool = true, beforeAnimation: (() -> ())? = nil, completion: @escaping (Bool) -> ()) {
        if let arkitView = arkitView, let scene = scenes.last/*, cameraPoses.count == scenes.count*/ {
            currentScene = nil
            anchorNode = nil
            mainNode = nil
            let previous = scenes.count > 1 ? scenes[scenes.count-2] : nil
            
            let isEnabledObjects = updateScale && !self.lastScale.isLocal && scaleCalculationType.isArkitEnabled ? false : isEnabled
            
            if let transformAB = calculateABTransform(cameraTransform: double4x4(cameraPoses.last!.pose), updateScale: updateScale) {
                if scene.restoreScene(transformAB: transformAB, arkitView: arkitView, isEnabled: isEnabledObjects) {
                
                    if updateScale, let scale = self.arkitScale(cameraPosition: double4x4(self.cameraPoses.last!.pose).position, transformAB: transformAB) {
                        self.lastScale = .arkit(value: scale)
                        
                        print("[loc] arkit scale: \(scale)")
                        
                        self.clearArkitScene()
                        return self.showLastScene(updateScale: false, isEnabled: isEnabled, animated: animated, beforeAnimation: beforeAnimation, completion: completion)
                    }
                    
                    self.currentScene = scene
                    beforeAnimation?()
                    
                    if animated, let prev = previous, let actions = scene.prepareActions(prevScene: prev, duration: self.animationDuration) {
                        scene.arObjectsEnabled = isEnabled
                        scene.animateRestoreScene(actions: actions) {
                            if isEnabled {
                                scene.drawEdges()
                            }
                            completion(true)
                        }
                        return
                    } else {
                        if isEnabled {
                            scene.arObjectsEnabled = isEnabled
                            scene.drawEdges()
                        }
                        completion(true)
                        return
                    }
                    
                }
            }
        }
        
        completion(false)
    }
    
    private func arkitScale(cameraPosition: simd_double3, transformAB: double4x4) -> Double? {
        guard let arkitView = arkitView, !self.lastScale.isLocal, let scene = scenes.last, scaleCalculationType.isArkitEnabled else {
            return nil
        }
        
        let size = UIScreen.main.bounds
        var scale = 0.0
        var count = 0
        
        for node in (scene.nodes ?? []) {
            
            for pt in node.points {
                let tp = transformAB*simd_double4(simd_double3(pt), 1.0)
                let pt = arkitView.projectPoint(SCNVector3(Float(tp.x), Float(tp.y), Float(tp.z)))
                let pt2d = CGPoint(x: CGFloat(pt.x), y: CGFloat(pt.y))
                
                guard pt.x > 0 && pt.x < Float(size.width) && pt.y > 0 && pt.y < Float(size.height) else {
                    break
                }
                
                let planeResults = arkitView.hitTest(pt2d, types: arHitTestResult)
                    
                if let result = planeResults.last {
                    let d1 = length(simd_double3(result.worldTransform.position) - cameraPosition)
                    let d2 = length(simd_double3(tp.x, tp.y, tp.z) - cameraPosition)
                    
                    guard d1 <= arPlaneMaxDistance else {
                        print("[scale] plane distance limit exceeded: \(d1)")
                        break
                    }
                    
                    print("[scale] arkit d1:\(d1), d2:\(d2)")
                    
                    scale += d1/d2
                    count += 1
                }
            }
        }
        
        return count > 0 ? max(scale/Double(count), 0.01) : nil
    }
    
    func calc2DNodes(cameraPose: simd_float4x4, ignoreVisibility: Bool = true) -> [StickerModels.Node]? {
        guard let arkitView = arkitView, let scene = currentScene else {
            return nil
        }
        
        let mat = SCNMatrix4(cameraPose)
        let cameraDirection = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        let cameraPosition = SCNVector3(mat.m41, mat.m42, mat.m43)
        let size = UIScreen.main.bounds
        
        // update 2d stickers
        var nodesData: [StickerModels.Node] = []
        for (k, items) in scene.arfNodes {
            guard items.count > 3 else {
                continue
            }
            
            var points: [CGPoint] = []
            var center = SCNVector3()
            var visiblePoints = 0
            
            for item in items {
                let pos = item.worldPosition
                let pt = arkitView.projectPoint(pos)
                points.append(CGPoint(
                    x: CGFloat(pt.x),
                    y: CGFloat(pt.y)
                ))
                center += pos
                
                if pt.x > 0 && pt.x < Float(size.width) && pt.y > 0 && pt.y < Float(size.height) {
                    visiblePoints += 1
                }
            }
            
            center = center / Float(items.count)
            let pc = center - cameraPosition
            
            if ignoreVisibility {
                nodesData.append(StickerModels.Node(
                    distance: Double(pc.norma()),
                    id: k.hashValue,
                    points: points
                ))
            } else {
                let angle: Float = acos((cameraDirection.x*pc.x + cameraDirection.y*pc.y + cameraDirection.z*pc.z)/(cameraDirection.norma()*pc.norma()))
                
                if angle < Float.pi/2 - 0.2 { //fix markers which are still projection-zombies =)
                    nodesData.append(StickerModels.Node(
                        distance: Double(pc.norma()),
                        id: k.hashValue,
                        points: points
                    ))
                }
            }
        }
        
        //print("[check] check calc2DNodes")
        return nodesData
    }
    
    private func isStickerVisible(_ nodes: [SCNNode]) -> Bool {
        guard let arkitView = arkitView else {
            return false
        }
        
        let size = UIScreen.main.bounds
        for node in nodes {
            let pt = arkitView.projectPoint(node.worldPosition)
            if pt.x < 0 || pt.x > Float(size.width) || pt.y < 0 || pt.y > Float(size.height) {
                return false
            }
        }
        
        return true
    }
    
    func getMainNode(ignoreLimits: Bool = false) -> Node3D? {
        guard let scene = currentScene, let arkitView = arkitView else {
            return nil
        }
        
        var visible: [(node: Node3D, size: Float)] = []
        
        for (k, items) in scene.arfNodes {
            if isStickerVisible(items) {
                guard let node = scene.nodes!.first(where: {$0.id == k}) else {
                    fatalError("invalid node id")
                }
                
                let pt0 = arkitView.projectPoint(items[0].worldPosition)
                let pt2 = arkitView.projectPoint(items[2].worldPosition)
                let size = length(simd_float2(pt0.x, pt0.y) - simd_float2(pt2.x, pt2.y))
                
                if size > minPatchScreeSizeLimit || ignoreLimits {
                    visible.append((node, size))
                }
            }
        }
        
        if visible.count > 0 {
            visible.sort(by: {$0.size > $1.size})
            return visible.first?.node
        }
        
        return nil
    }
    
    func createImageRef(orientation: CGImagePropertyOrientation) -> (patch: UIImage, ref: ARReferenceImage)? {
        guard let arkitView = arkitView, let scene = currentScene, let capturedImage = arkitView.session.currentFrame?.capturedImage else {
            return nil
        }
        
        mainNode = getMainNode(ignoreLimits: true)
        
        if mainNode != nil, let items = scene.arfNodes[mainNode!.id] {
            
            guard var triples = Scene3D.sortRectNodes(arkitView: arkitView, items: items) else {
                return nil
            }
            
            let physicalWidth = length(triples[0].node.simdWorldPosition - triples[1].node.simdWorldPosition)
            
            guard physicalWidth < physicalWidthLimit else {
                return nil
            }
            
            var points: [simd_float2] = triples.map {$0.pt}
            
            if distance(triples[0].pt, triples[1].pt) < imageAnchorPointLimit, distance(triples[0].pt, triples[3].pt) < imageAnchorPointLimit {
                var center = points.reduce(into: simd_float2(0, 0), { acc, val in
                    acc = acc + val
                })
                
                center = center/Float(points.count)
                points = [
                    (center - simd_float2(imageAnchorPointLimit/2, imageAnchorPointLimit/2)),
                    (center + simd_float2(imageAnchorPointLimit/2, -imageAnchorPointLimit/2)),
                    (center + simd_float2(imageAnchorPointLimit/2, imageAnchorPointLimit/2)),
                    (center + simd_float2(-imageAnchorPointLimit/2, imageAnchorPointLimit/2))
                ]
            }
            
            let ciImage = CIImage(cvPixelBuffer: capturedImage)
            let image = UIImage(ciImage: ciImage).rotate(radians: .pi/2)!
            
            let screenSize = arkitView.frame.size //UIScreen.main.bounds.size
            let scale = image.size.height/screenSize.height
            let dx = ceil((image.size.width - scale*screenSize.width)/2)
            
            if let output = image.perspectiveCorrection(
                topLeft: CGPoint(x: CGFloat(points[0].x)*scale + dx,
                                 y: CGFloat(points[0].y)*scale),
                topRight: CGPoint(x: CGFloat(points[1].x)*scale + dx,
                                  y: CGFloat(points[1].y)*scale),
                bottomRight: CGPoint(x: CGFloat(points[2].x)*scale + dx,
                                     y: CGFloat(points[2].y)*scale),
                bottomLeft: CGPoint(x: CGFloat(points[3].x)*scale + dx,
                                    y: CGFloat(points[3].y)*scale)) {
                
                print("[image anchor] create ref image physicalWidth:\(physicalWidth)")
                let referenceImage = ARReferenceImage(output.cgImage!, orientation: orientation, physicalWidth: CGFloat(physicalWidth))

                return (output, referenceImage)
            }
        }
        return nil
    }
    
    func rebaseToAnchorNode(_ node: SCNNode) {
        guard let _ = arkitView, let scene = currentScene else {
            return
        }
        
        for (_, items) in scene.arfNodes {
            for item in items {
                if item.parent === node {
                    continue
                }
                let pos = item.worldPosition
                item.removeFromParentNode()
                node.addChildNode(item)
                item.worldPosition = pos
            }
        }
        
        for (_, items) in scene.arfNodes {
            for (index, item) in items.enumerated() {
                var next = items[0]
                if index < items.count - 1 {
                    next = items[index + 1]
                }
                
                if let line = item.childNodes.first(where: {$0 is ARFLineNode}) as? ARFLineNode {
                    line.to = item.convertPosition(next.worldPosition, from: nil)
                }
            }
        }
        
        anchorNode = node
    }
    
    func isMainNodeChanged() -> Bool {
        let node = getMainNode()
        return node != nil && mainNode != node
    }
    
    func rebaseStickersToMainNode(_ mainNode: Node3D) {
        guard let arkitView = arkitView, let scene = currentScene else {
            return
        }
        
        guard let nodes = scene.arfNodes[mainNode.id] else {
            return
        }
        
        self.mainNode = mainNode
        
        if let tf_s0_a = calculateSceneTransform(nodes: nodes) {
            scene.simdTransform = tf_s0_a
            arkitView.scene.rootNode.addChildNode(scene)
            
            for (k, items) in scene.arfNodes {
                if mainNode.id == k {
                    continue
                }
                
                for item in items {
                    let pos = item.worldPosition
                    scene.addChildNode(item)
                    item.worldPosition = pos
                }
                
                for (index, item) in items.enumerated() {
                    var next = items[0]
                    if index < items.count - 1 {
                        next = items[index + 1]
                    }
                    
                    if let line = item.childNodes.first(where: {$0 is ARFLineNode}) as? ARFLineNode {
                        line.to = item.convertPosition(next.position, from: scene)
                    }
                }
            }
        }
    }
    
    func fixPosition(anchor: ARAnchor) {
        guard let arkitView = arkitView, let scene = currentScene, let nodeId = mainNode?.id, let mainItems = scene.arfNodes[nodeId] else {
            return
        }
        
        for (_, nodes) in scene.arfNodes {
            guard let triples = Scene3D.sortRectNodes(arkitView: arkitView, items: nodes) else {
                continue
            }
            
            let items = triples.map {$0.node}
            
            for (index, item) in items.enumerated() {
                if item.name == anchor.name {
                    item.simdTransform = anchor.transform
                    
                    var prev = items.last!
                    if index > 0 {
                        prev = items[index-1]
                    }
                    
                    if let line = prev.childNodes.first as? ARFLineNode {
                        line.to = prev.convertPosition(item.worldPosition, from: nil)
                    }
                }
                
                var next = items[0]
                if index < items.count - 1 {
                    next = items[index + 1]
                }
                
                if let line = item.childNodes.first as? ARFLineNode {
                    line.to = item.convertPosition(next.worldPosition, from: nil)
                }
            
            }
        }
        
        if let tf_s0_a = calculateSceneTransform(nodes: mainItems) {
            DispatchQueue.main.async {
                scene.simdTransform = tf_s0_a
            }
        }
    }
    

}
