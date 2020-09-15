//
//  double4x4+adds.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 08/08/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import ARKit

extension double4x4 {
    var position: simd_double3 {
        return simd_double3(self.columns.3.x, self.columns.3.y, self.columns.3.z)
    }
    
    init(_ mat: float4x4) {
        self = double4x4(
            simd_double4(mat.columns.0),
            simd_double4(mat.columns.1),
            simd_double4(mat.columns.2),
            simd_double4(mat.columns.3))
    }
    
    var upperLeft3x3: double3x3 {
        let (a,b,c,_) = columns
        return double3x3(a.xyz, b.xyz, c.xyz)
    }
    
    init(rotation: double3x3, position: simd_double3) {
        let (a,b,c) = rotation.columns
        self = double4x4(simd_double4(a, 0),
                         simd_double4(b, 0),
                         simd_double4(c, 0),
                         simd_double4(position, 1))
    }
}
