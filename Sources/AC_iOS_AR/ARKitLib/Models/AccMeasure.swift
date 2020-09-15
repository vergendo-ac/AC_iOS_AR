//
//  AccMeasure.swift
//  Developer
//
//  Created by Andrei Okoneshnikov on 17.02.2020.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation
import ARKit

class AccMeasure {
    var t: Double
    var v: simd_double3
    var a: simd_double3
    var x: simd_double3
    var arkitX: simd_float3
    
    init(_ a: simd_double3, v: simd_double3 = simd_double3(), x: simd_double3 = simd_double3(), arkitX: simd_float3 = simd_float3()) {
        t = Date().timeIntervalSince1970
        self.a = a
        self.v = v
        self.x = x
        self.arkitX = arkitX
    }
}
