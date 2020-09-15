//
//  ArCreatureManager.swift
//  YaPlace
//
//  Created by Mac on 14.04.2020.
//  Copyright © 2020 SKZ. All rights reserved.
//

import ARKit

class ArCreatureManager: ArManager {
    
    static let sharedInstance = ArCreatureManager()
    
    private var allCreatureNodes: [SCNNode] = []
    private var superView: UIView?
    
    var arCreatureEnabled = false {
        didSet {
            for node in allCreatureNodes {
                node.isHidden = !arCreatureEnabled
            }
        }
    }

    
    override init() {
        super.init()
        self.arCreatureEnabled = UserDefaults.arCreatures ?? false
    }

    deinit {
       clear()
    }

    func clear() {
       for node in allCreatureNodes {
           node.removeFromParentNode()
       }
       allCreatureNodes = []
       arkitView = nil
    }
    
    func set(superView: UIView) {
       self.superView = superView
    }
    
    func setupGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.arkitView?.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! ARSCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        
        if sender.state == .ended {

            let hitTest = sceneViewTappedOn.hitTest(touchCoordinates, options: nil)
            if !hitTest.isEmpty, let tappedNode = hitTest.first?.node, let rootNode = getRoot(for: tappedNode), let name = rootNode.name,
            Sticker3DHelper.sharedInstance.stickersNames().contains(name),
            let normalVector = rootNode.value(forKey: "normalVector") as? SCNVector3 {
                print(name)
                
                rootNode.isHidden = true
                self.putOcclusionPlane(at: rootNode.simdWorldOrientation, with: rootNode.position, by: normalVector)
                print(rootNode.position)
                print(rootNode.worldPosition)
                self.putCreature(by: normalVector, with: rootNode.simdWorldPosition, orientation: rootNode.orientation)

                rootNode.removeFromParentNode()
            }
            
        }

    }
    
    private func putOcclusionPlane(at orientation: simd_quatf, with position: SCNVector3, by normal: SCNVector3) {
        //let creature = USDZhelper.sharedInstance.getUSDZnode(with: "")
        //let creature = ARFTraceNode(name: UUID().uuidString).node!
            //creature.worldOrientation = orientation
        let size = CGSize(width: 3.0, height: 3.0)
        
        let geometry = SCNPlane(width: size.width, height: size.height)
        geometry.firstMaterial?.diffuse.contents = UIColor.green
        geometry.firstMaterial?.isDoubleSided = true

        //let plane = SCNNode(geometry: geometry)
        //plane.opacity = 0.5
        
        let plane = createOcclusionPlane(with: size)
        
        plane.isHidden = false
            
        plane.simdWorldOrientation = orientation
        plane.position = position - normal * 0.1
        
        //print(position)
        //print(orientation)

        DispatchQueue.main.async {
            self.arkitView?.scene.rootNode.addChildNode(plane)
        }
        
    }
    
    private func putCreature(by normal: SCNVector3, with position: simd_float3, orientation: SCNQuaternion) {
        guard let usdzName = UserDefaults.current3DSticker else { return }
        guard let creature = ARFUSDZNode(name: usdzName, radius: 0.5).usdzNode else { return }
        //guard let cameraPos = arkitView?.session.currentFrame?.camera.transform.position else { return }

        creature.worldPosition = SCNVector3(position) - normal * 2
            //position - (cameraPos - position)/2
        creature.orientation = orientation
        
        let destinationPoint = SCNVector3(position) + normal * 2
            //SCNVector3(position + (cameraPos - position)/3)
        let animationDuration: TimeInterval = 7.0
        
        DispatchQueue.main.async {
            self.arkitView?.scene.rootNode.addChildNode(creature)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let action = SCNAction.move(to: destinationPoint, duration: animationDuration)
            creature.runAction(action)
        }
        
    }

    private func getRoot(for node: SCNNode) -> SCNNode? {
        if let node = node.parent, node != self.arkitView?.scene.rootNode {
            return getRoot(for: node)
        } else {
            return node
        }
    }
    
    func createOcclusionPlane(with size: CGSize = CGSize(width: 1.0, height: 1.0)) -> SCNNode {
        let plane = SCNNode(geometry: SCNPlane(width: size.width, height: size.height))
        
        plane.geometry?.firstMaterial = occlusion()
        plane.renderingOrder = -100
        
        return plane
    }
    
    func occlusion() -> SCNMaterial {

        let occlusionMaterial = SCNMaterial()
        occlusionMaterial.isDoubleSided = true
        occlusionMaterial.colorBufferWriteMask = []
        occlusionMaterial.readsFromDepthBuffer = true
        occlusionMaterial.writesToDepthBuffer = true

        return occlusionMaterial
    }

    
}
