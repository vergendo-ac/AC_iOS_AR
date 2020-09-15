//
//  float3+adds.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 09/08/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import ARKit

extension simd_float3 {
    static func vecmul(_ a: simd_float3, _ b: simd_float3) -> simd_float3 {
        let res = simd_float3(a.y * b.z - b.y * a.z, a.z * b.x - b.z * a.x, a.x * b.y - b.x * a.y)
        return res
    }
    
    static func scalar(_ a: simd_float3, _ b: simd_float3) -> Float {
        let res = a.x * b.x + a.y * b.y + a.z * b.z
        return res
    }
    
    func norma() -> Float {
        return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    }
}
