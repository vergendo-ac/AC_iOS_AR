//
//  ServerCamera+ext.swift
//  YaPlace
//
//  Created by Andrei Okoneshnikov on 02.09.2020.
//  Copyright © 2020 SKZ. All rights reserved.
//

import ARKit

extension ServerCamera {
    static func create(from pose: Pose) -> ServerCamera {
        return ServerCamera(position: simd_float3(pose.position.x, pose.position.y, pose.position.z), orientation: simd_quatf(real: pose.orientation.w, imag: simd_float3(pose.orientation.x, pose.orientation.y, pose.orientation.z)))
    }
}
