//
//  CGPoint+adds.swift
//  myPlace
//
//  Created by Mac on 12/12/2018.
//  Copyright © 2018 Unit. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint {
    
    public static let one: CGPoint = CGPoint(x: 1, y: 1)

    public func add(to point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + point.x, y: self.y + point.y)
    }
    
    public func mul(to val: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * val, y: self.y * val)
    }
    
    public func mulXY(to xVal: CGFloat, and yVal: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * xVal, y: self.y * yVal)
    }
    
}
