//
//  float4x4+adds.swift
//  Developer
//
//  Created by Andrei Okoneshnikov on 08/08/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import ARKit

extension float4x4 {
    var upperLeft3x3: simd_float3x3 {
        let (a,b,c,_) = columns
        return simd_float3x3(a.xyz, b.xyz, c.xyz)
    }
    
    init(rotation: simd_float3x3, position: simd_float3) {
        let (a,b,c) = rotation.columns
        self = float4x4(simd_float4(a, 0),
                        simd_float4(b, 0),
                        simd_float4(c, 0),
                        simd_float4(position, 1))
    }
    
    var position: simd_float3 {
        return simd_float3(self.columns.3.x, self.columns.3.y, self.columns.3.z)
    }
    
    var location: SCNVector3 {
        let locCol = self.columns.3
        return SCNVector3(locCol.x, locCol.y, locCol.z)
    }
    
    init(_ mat: simd_double4x4) {
        self = simd_float4x4(
            simd_float4(mat.columns.0),
            simd_float4(mat.columns.1),
            simd_float4(mat.columns.2),
            simd_float4(mat.columns.3))
    }
}
