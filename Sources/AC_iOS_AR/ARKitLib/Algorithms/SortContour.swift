//
//  SortContour.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 15/08/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import ARKit

func clockwiseRectNodesSort(items: [(pt: float2, node: SCNNode)]) -> [(pt: float2, node: SCNNode, angle: Float)]? {
    guard items.count == 4 else {
        return nil
    }
    
    // sort points
    var points = items
    
    points.sort(by: {$0.pt.x < $1.pt.x})
    let v1 = float2(0, -1)
    let p0 = points[0]
    var triples: [(pt: float2, node: SCNNode, angle: Float)] = [(p0.pt, p0.node, 0)]
    
    for index in 1..<points.count {
        let item = points[index]
        let v2 = simd_normalize(item.pt - p0.pt)
        let angle = acos((v1.x*v2.x + v1.y*v2.y)/(length(v1)*length(v2)))
        triples.append((item.pt, item.node, angle))
    }
    
    triples.sort(by: {$0.angle < $1.angle})
    
    var result = triples
    let alpha = triples[1].angle
    let beta = Float.pi - triples[3].angle
    
    if triples[0].pt.y > triples[1].pt.y && alpha < beta {
        result[0] = triples[1]
        result[1] = triples[2]
        result[2] = triples[3]
        result[3] = triples[0]
    }
    
    return result
}
