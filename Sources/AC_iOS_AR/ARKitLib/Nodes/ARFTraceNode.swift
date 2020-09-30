//
//  ARFTraceNode.swift
//  YaPlace
//
//  Created by Mac on 09.04.2020.
//  Copyright © 2020 SKZ. All rights reserved.
//

import Foundation
import ARKit

class ARFTraceNode {
    
    var node: SCNNode!
    
    init(name: String, radius: Float = 0.2) {
        let tempScene = SCNScene(named: "Sources/AC_iOS_AR/ARKitLib/Objects/art.scnassets/tiger_paw/tiger_paw_footprint.scn")
        self.node = tempScene?.rootNode
        self.node.name = name
        print(self.node.childNodes)
        print(self.node.childNodes.count)
        self.radius = radius
        //self.setPivot()
    }
    
    deinit {
        node = nil
    }
    
    public var radius: Float? {
        get {
            return self.node?.boundingSphere.radius
        }
        set {
            if let value = newValue {
                scale(node, to: SCNVector3(value * 2.0, value * 2.0, value * 2.0))
            }
        }
    }
    
    func scale(_ node: SCNNode?, to normalSize: SCNVector3 = SCNVector3(0.15, 0.15, 0.15)) {
        if node != nil {
            node!.scale = normalSize.scale(from: node!.boundingSphere.radius * 2.0)
        }
    }
    
    private func setPivot() {
        if let node = self.node {
            let minVec = node.boundingBox.min
            let maxVec = node.boundingBox.max
            let bound = SCNVector3Make(maxVec.x - minVec.x, maxVec.y - minVec.y, maxVec.z - minVec.z)
            node.pivot = SCNMatrix4MakeTranslation(minVec.x + (bound.x / 2), minVec.y + (bound.y / 2), 0)
        }
    }
}
