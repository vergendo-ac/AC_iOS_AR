//
//  SCNVector3+adds.swift
//  arfunit
//
//  Created by Andrei Okoneshnikov on 19/04/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import ARKit

extension SCNVector3 {
    static func + (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
        return SCNVector3(l.x + r.x, l.y + r.y, l.z + r.z)
    }

    static func + (l: SCNVector3, r: Float) -> SCNVector3 {
        return SCNVector3(l.x + r, l.y + r, l.z + r)
    }

    static func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
        return SCNVector3(l.x - r.x, l.y - r.y, l.z - r.z)
    }
    
    static func - (l: SCNVector3, r: Float) -> SCNVector3 {
        return SCNVector3(l.x - r, l.y - r, l.z - r)
    }
    
    static func * (c: Float, r: SCNVector3) -> SCNVector3 {
        return SCNVector3(c * r.x, c * r.y, c * r.z)
    }
    
    static func * (r: SCNVector3, c: Float) -> SCNVector3 {
        return c * r
    }
    
    static func += (l: inout SCNVector3, r: SCNVector3) {
        l = l + r
    }
    
    static func -= (l: inout SCNVector3, r: SCNVector3) {
        l = l - r
    }
    
    static func / (l: SCNVector3, r: Float) -> SCNVector3 {
        return SCNVector3(l.x / r, l.y / r, l.z / r)
    }
    
    static func /= (l: inout SCNVector3, r: Float) {
        l = l / r
    }
    
    static func / (l: SCNVector3, r: Int) -> SCNVector3 {
        return SCNVector3(l.x / Float(r), l.y / Float(r), l.z / Float(r))
    }
    
    static func /= (l: inout SCNVector3, r: Int) {
        l = l / r
    }
    
    static func *= (l: inout SCNVector3, r: Float) {
        l = l * r
    }
    
    static func *= (l: inout SCNVector3, r: CGFloat) {
        l = l * Float(r)
    }
    
    static func positionFromTransform(_ t: matrix_float4x4) -> SCNVector3 {
        return SCNVector3(t.columns.3.x, t.columns.3.y, t.columns.3.z)
    }
    
    static func positionFromTransform(_ t: SCNMatrix4) -> SCNVector3 {
        return SCNVector3Make(t.m41, t.m42, t.m43)
    }
    
    mutating func normalize() {
        let l = self.length()
        self.x /= l
        self.y /= l
        self.z /= l
    }
    
    func norma() -> Float {
        return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    }
    
    func isEqual(_ vec: SCNVector3) -> Bool {
        return self.x == vec.x && self.y == vec.y && self.z == vec.z
    }

    func scale(from size: Float) -> SCNVector3 {
        let res = SCNVector3(self.x / size, self.y / size, self.z / size)
        return res
    }

    static func vecmul(a: SCNVector3, b: SCNVector3) -> SCNVector3 {
        let res = SCNVector3(a.y * b.z - b.y * a.z, a.z * b.x - b.z * a.x, a.x * b.y - b.x * a.y)
        return res
    }
    
    static func scalar(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        let res = a.x * b.x + a.y * b.y + a.z * b.z
        return res
    }
    
    /**
    * Returns the length (magnitude) of the vector described by the SCNVector3
    */
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
    
    /**
    * Calculates the distance between two SCNVector3. Pythagoras!
    */
    func distance(to vector: SCNVector3) -> Float {
        return (self - vector).length()
    }
    
    func offset(x: Float = .zero, y: Float = .zero, z: Float = .zero) -> SCNVector3 {
        SCNVector3(x: self.x + x, y: self.y + y, z: self.z + z)
    }

}
