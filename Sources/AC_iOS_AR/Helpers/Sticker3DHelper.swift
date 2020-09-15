//
//  Sticker3DHelper.swift
//  MyPlaceLibIOS
//
//  Created by Mac on 30.01.2020.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation

class Sticker3DHelper {
    
    static let sharedInstance = Sticker3DHelper()
    
    enum Sticker3DSourceType {
        case usdz(name: String)
        case particleSystem(name: String)
        case googlePoly(name: String)
        case scnScene(name: String)
        case none
        
        var name: String {
            switch self {
                case .usdz(let name): return name
                case .particleSystem(let name): return name
                case .googlePoly(let name): return name
                case .scnScene(let name): return name
                case .none: return "No 3D sticker"
            }
        }
    }
    
    let stickers3D: [Sticker3DSourceType] = [
        .none,
        .usdz(name: "spherebot2"),
        .usdz(name: "starball"),
        .usdz(name: "cubesolve"),
        .usdz(name: "dragon"),
        .usdz(name: "butterfly5")
    ]
    
    func stickersNames() -> [String] {
        return stickers3D.map { $0.name }
    }
    
}
