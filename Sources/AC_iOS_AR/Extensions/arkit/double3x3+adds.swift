//
//  double3x3+adds.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 08/08/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import ARKit

extension double3x3 {
    init(_ quatf: simd_quatf) {
        self = double3x3(simd_quatd(real: Double(quatf.real),
                                    imag: double3(quatf.imag)))
    }
}
