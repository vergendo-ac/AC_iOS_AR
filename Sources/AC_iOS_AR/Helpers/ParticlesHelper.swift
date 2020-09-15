//
//  ParticlesHelper.swift
//  MyPlaceLibIOS
//
//  Created by Mac on 28.01.2020.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation
import ARKit

class ParticlesHelper {
    
    public static let sharedInstance = ParticlesHelper()
    
    private var currentNodes: [String:SCNNode] = [:]
    
    init() {
        _ = self.getParticlesNode(with: "fire")
    }

    func getParticlesNode(with name: String) -> SCNNode {
        
        guard currentNodes[name] == nil else { return currentNodes[name]! }
        
        guard let particleSystem = SCNParticleSystem(named: "\(name).scnp", inDirectory: nil) else { fatalError() }
        
        let particlesNode = SCNNode()
        particlesNode.addParticleSystem(particleSystem)
        
        currentNodes[name] = particlesNode
        
        return particlesNode
    }
    
}
