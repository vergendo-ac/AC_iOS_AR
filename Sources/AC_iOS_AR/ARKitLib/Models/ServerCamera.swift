//
//  ServerCamera.swift
//  Developer
//
//  Created by Andrei Okoneshnikov on 20/06/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation

import Foundation
//import Alamofire
//import SwiftyJSON
import ARKit

class ServerCamera {
    var position: simd_float3
    var orientation: simd_quatf
    
    init(position: simd_float3, orientation: simd_quatf) {
        self.position = position
        self.orientation = orientation
    }
    
    init(json: JSON) {
        
        if let components = json["position"].array, components.count > 2 {
            position = simd_float3(x: components[0].floatValue, y: components[1].floatValue, z: components[2].floatValue)
            print("[parse] camera positoin:\(position)")
        } else {
            fatalError("Invalid camera position")
        }
        
        if let components = json["orientation"].array, components.count > 3 {
            orientation = simd_quatf(real: components[3].floatValue, imag: simd_float3(x: components[0].floatValue, y: components[1].floatValue, z: components[2].floatValue))
            print("[parse] camera orientation:\(orientation), angle:\(orientation.angle), axis:\(orientation.axis)")
        } else {
            fatalError("Invalid camera orientation")
        }
    }
}
