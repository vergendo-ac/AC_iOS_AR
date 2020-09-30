//
//  Node3D+ext.swift
//  YaPlace
//
//  Created by Andrei Okoneshnikov on 02.09.2020.
//  Copyright © 2020 SKZ. All rights reserved.
//

import Foundation
import ARKit

extension Node3D {
    
    static func defaultFrame() -> [Vector3d] {
        let result: [Vector3d] = [
            Vector3d(x: -0.2, y: 0.2, z: 0),
            Vector3d(x: 0.2, y: 0.2, z: 0),
            Vector3d(x: 0.2, y: -0.2, z: 0),
            Vector3d(x: -0.2, y: -0.2, z: 0)
        ]
        return result
    }
    
    static func create(from placeholder: PlaceholderNode3d) -> Node3D {
        var points: [simd_float3] = []
        
        let orientation = placeholder.pose.orientation
        let qr = simd_quatf(real: orientation.w, imag: simd_float3(orientation.x, orientation.y, orientation.z))
        let transform = simd_float4x4(rotation: simd_float3x3(qr), position: simd_float3(placeholder.pose.position.x, placeholder.pose.position.y, placeholder.pose.position.z))
        
        for point in placeholder.frame ?? self.defaultFrame() {
            let tp = transform * simd_float4(simd_float3(point.x, point.y, point.z), 1.0)
            let p = simd_float3(tp.x, tp.y, tp.z)
            points.append(p)
        }
        
        let node = Node3D(id: placeholder.placeholderId, points: points)
        return node
    }
}
