//
//  ABTransform.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 09/08/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import ARKit

func iverseMatrix(_ matrix: simd_double4x4) -> double4x4 {
    let rotation = matrix.upperLeft3x3
    let position = matrix.position
    
    let newPosition = -rotation.transpose*position
    return double4x4(rotation: rotation.transpose, position: newPosition)
}

// Transform matrix from server coordinate system to arkit system
func srvToArkitTransform(arkit: double4x4, server: double4x4, scale: Double) -> double4x4 {
    let sc = double4x4(diagonal: simd_double4(scale, scale, scale, 1))
    
    let tf_cb_ca = simd_double4x4(
        simd_double4(0, 1, 0, 0),
        simd_double4(1, 0, 0, 0),
        simd_double4(0, 0, -1, 0),
        simd_double4(0, 0, 0, 1))
    
    let tf_b_cb = iverseMatrix(server) //server.inverse
    let tf_ca_a = arkit
    let tf_b_a =  (tf_ca_a * tf_cb_ca) * sc * tf_b_cb
    
    return tf_b_a
}

func calculateStickerTransform(points: [simd_float3]) -> float4x4? {
    guard points.count == 3 else {
        return nil
    }
    
    /*
     tf_s0_a = [R, t; 0 0 0 1], где столбцами матрицы R являются вектора
     x = (с1-c0)/||c1-c0||,
     y = (c2-c0)/||c2-c0|| - x*<x,(c2-c0)/||c2-c0||>,
     z = cross(x,y), а вектор t = c0. Здесь ci являются координатами углов стикера против часовой стрелки.
     */
    
    let c0 = points[0]
    let c1 = points[1]
    let c2 = points[2]
    
    guard (c1 - c0).norma() > 0, (c2 - c0).norma() > 0, (c1 - c2).norma() > 0 else {
        return nil
    }
    
    let colX = normalize(c1 - c0)
    let c2c0 = normalize(c2 - c0)
    let colY = normalize(c2c0 - colX * simd_float3.scalar(colX, c2c0))
    let colZ = simd_float3.vecmul(colX, colY)
    
    let rot = float3x3([colX.x, colX.y, colX.z],
                       [colY.x, colY.y, colY.z],
                       [colZ.x, colZ.y, colZ.z])
    
    return float4x4(rotation: rot, position: c0)
}
