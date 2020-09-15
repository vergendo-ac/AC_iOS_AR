//
//  ParticlesNode.swift
//  MyPlaceLibIOS
//
//  Created by Mac on 28.01.2020.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation
import ARKit

class ParticlesNode {
    
    var particlesNode: SCNNode?
    
    init(name: String, radius: Float = 0.5) {
        
        self.particlesNode = ParticlesHelper.sharedInstance.getParticlesNode(with: name).clone()
        
        //self.radius = radius
        self.setPivot()
    }
    
    deinit {
        
    }
    
    public var radius: Float? {
        get {
            return self.particlesNode?.boundingSphere.radius
        }
        set {
            if let value = newValue {
                scale(particlesNode, to: SCNVector3(value * 2.0, value * 2.0, value * 2.0))
            }
        }
    }
    
    func scale(_ node: SCNNode?, to normalSize: SCNVector3 = SCNVector3(0.15, 0.15, 0.15)) {
        if node != nil {
            node!.scale = normalSize.scale(from: node!.boundingSphere.radius * 2.0)
        }
    }
    
    private func setPivot() {
        if let node = particlesNode {
            let minVec = node.boundingBox.min
            let maxVec = node.boundingBox.max
            let bound = SCNVector3Make(maxVec.x - minVec.x, maxVec.y - minVec.y, maxVec.z - minVec.z)
            node.pivot = SCNMatrix4MakeTranslation(minVec.x + (bound.x / 2), minVec.y + (bound.y / 2), 0)
        }
    }
    
}
