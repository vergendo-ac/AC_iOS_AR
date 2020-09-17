//
//  PointModels.swift
//  myPlace
//
//  Created by Mac on 31.07.2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import CoreGraphics

enum PointModels {
    
    typealias DistantPoint = (Double?, CGPoint)
    typealias DistantFramePoints = (Double?, [CGPoint])

    struct TripleCentralPoints {
        let leftPoints: [Int:DistantPoint]?
        let centralPoints: [Int:DistantPoint]?
        let rightPoints: [Int:DistantPoint]?
        let framePoints: [Int:DistantFramePoints]?
        let allPoints: [Int:DistantPoint]?
    }
    
}
