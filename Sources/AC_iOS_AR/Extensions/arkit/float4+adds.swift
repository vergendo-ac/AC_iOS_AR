//
//  float4.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 08/08/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import ARKit

extension float4 {
    var xyz: float3 {
        return float3(x, y, z)
    }
    
    init(_ vec3: float3, _ w: Float) {
        self = float4(vec3.x, vec3.y, vec3.z, w)
    }
    
    init(_ vec4: double4) {
        self = float4(Float(vec4.x), Float(vec4.y), Float(vec4.z), Float(vec4.w))
    }
}
