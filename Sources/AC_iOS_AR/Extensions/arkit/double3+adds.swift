//
//  double3+adds.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 08/08/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import ARKit

extension simd_double3 {
    init(_ vec3: simd_float3) {
        self = simd_double3(Double(vec3.x), Double(vec3.y), Double(vec3.z))
    }
    
    func norma() -> Double {
        return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    }
}
