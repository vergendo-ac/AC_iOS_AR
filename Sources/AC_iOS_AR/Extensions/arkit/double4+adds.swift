//
//  double4+adds.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 08/08/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import ARKit

extension simd_double4 {
    var xyz: simd_double3 {
        return simd_double3(x, y, z)
    }
    
    init(_ vec3: simd_double3, _ w: Double) {
        self = simd_double4(vec3.x, vec3.y, vec3.z, w)
    }
    
    init(_ vec4: simd_float4) {
        self = simd_double4(Double(vec4.x), Double(vec4.y), Double(vec4.z), Double(vec4.w))
    }
}


