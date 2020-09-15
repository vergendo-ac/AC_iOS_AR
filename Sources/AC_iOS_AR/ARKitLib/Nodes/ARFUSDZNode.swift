//
//  ARFUSDZNode.swift
//  MyPlaceLibIOS
//
//  Created by Mac on 26.01.2020.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation
import ARKit

class ARFUSDZNode {
    
    var usdzNode: SCNNode?
    
    var framePoints: [SCNVector3]
    
    init(name: String, radius: Float = 0.2, framePoints: [SCNVector3] = []) {
        self.usdzNode = USDZhelper.sharedInstance.getUSDZnode(with: name)?.clone()
        self.framePoints = framePoints
        self.radius = radius
        self.usdzNode?.name = name
        //self.setPivot()
    }
    
    deinit {
        
    }
    
    public var radius: Float? {
        get {
            return self.usdzNode?.boundingSphere.radius
        }
        set {
            if let value = newValue {
                scale(usdzNode, to: SCNVector3(value * 2.0, value * 2.0, value * 2.0))
            }
        }
    }
    
    func scale(_ node: SCNNode?, to normalSize: SCNVector3 = SCNVector3(0.15, 0.15, 0.15)) {
        if node != nil {
            node!.scale = normalSize.scale(from: node!.boundingSphere.radius * 2.0)
        }
    }
    
    private func setPivot() {
        if let node = usdzNode {
            let minVec = node.boundingBox.min
            let maxVec = node.boundingBox.max
            let bound = SCNVector3Make(maxVec.x - minVec.x, maxVec.y - minVec.y, maxVec.z - minVec.z)
            node.pivot = SCNMatrix4MakeTranslation(minVec.x + (bound.x / 2), minVec.y + (bound.y / 2), 0)
        }
    }
}
