//
//  USDZhelper.swift
//  MyPlaceLibIOS
//
//  Created by Mac on 27.01.2020.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation
import ARKit

class USDZhelper {
    
    public static let sharedInstance = USDZhelper()
    
    private var currentNodes: [String:SCNNode] = [:]
    
    init() {
        //_ = self.getUSDZnode(with: "spherebot2")
        //_ = self.getUSDZnode(with: "beemaya")
        //_ = self.getUSDZnode(with: "cityscape")
        //_ = self.getUSDZnode(with: "metalball")
        //_ = self.getUSDZnode(with: "Saturn2")
        //_ = self.getUSDZnode(with: "StoneHedge")
        //_ = self.getUSDZnode(with: "starball")
        //_ = self.getUSDZnode(with: "cubesolve")
        //_ = self.getUSDZnode(with: "dragon")
        //_ = self.getUSDZnode(with: "butterfly5")
    }

    func getUSDZnode(with name: String) -> SCNNode? {
        
        guard currentNodes[name] == nil else { return currentNodes[name] }
        
        guard let url = Bundle.main.url(forResource: "art.scnassets/usdz/\(name)", withExtension: "usdz") else { print("Wrong usdz name = \(name)"); return nil }
        
        let newNode = SCNReferenceNode(url: url)
        newNode?.loadingPolicy = .onDemand
        newNode?.load()
        
        currentNodes[name] = newNode
        
        return newNode
    }
    
    func cache(with name: String) {
        guard currentNodes[name] == nil else { return }
        _ = self.getUSDZnode(with: name)
    }
    
}
