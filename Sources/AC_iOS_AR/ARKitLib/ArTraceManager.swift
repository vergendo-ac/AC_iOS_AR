//
//  ArTraceManager.swift
//  YaPlace
//
//  Created by Mac on 14.04.2020.
//  Copyright © 2020 SKZ. All rights reserved.
//

import ARKit

class ArTraceManager: ArManager {
    
    static let sharedInstance = ArTraceManager()
    
    private var allTraceNodes: [SCNNode] = []

    private var lastTracePose: SCNVector3?
    
    private var traceScene: SCNScene!
    
    private var traceNode: ARFTraceNode?
    
    private var isRightTrace: Bool = true

    
    var arTracesEnabled = false {
        didSet {
            for node in allTraceNodes {
                node.isHidden = !arTracesEnabled
            }
        }
    }

    override init() {
        super.init()
        self.arTracesEnabled = UserDefaults.arTraces ?? false
        traceScene = SCNScene(named: "Sources/AC_iOS_AR/ARKitLib/Objects/art.scnassets/tiger_paw/tiger_paw_footprint.scn")
        arkitView?.scene.lightingEnvironment.contents = traceScene.lightingEnvironment.contents
    }
    
    deinit {
        clear()
    }
    
    
    func clear() {
        for node in allTraceNodes {
            node.removeFromParentNode()
        }
        allTraceNodes = []
        arkitView = nil
    }
    
    func updateTraces(cameraPose: simd_float4x4, cameraAngles: simd_float3, maxDistance: Float = 0.5) {
        if arTracesEnabled {

            let newLocation = cameraPose.location
        
            if lastTracePose == nil || lastTracePose!.distance(to: newLocation) > maxDistance {
                lastTracePose = newLocation
                drawTraceNode(at: newLocation.offset(y: -1.3), for: cameraAngles)
            }
            
        }
    }

    private func drawTraceNode(at point: SCNVector3, for angles: simd_float3) {
        guard let arkitView = self.arkitView else { return }
        if traceNode == nil {
            traceNode = ARFTraceNode(name: UUID().uuidString, radius: 0.1)
        }
        
        self.isRightTrace.toggle()
        
        let tNode = traceNode!.node.clone()
        tNode.isHidden = !(UserDefaults.arTraces ?? false)
        tNode.worldPosition = point
        print("traceNode angle_y = ", angles.y)
        tNode.eulerAngles.y = angles.y
        arkitView.scene.rootNode.addChildNode(tNode)
        allTraceNodes.append(tNode)
    }
    
}
