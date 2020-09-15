//
//  ARFLineNode.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 30/07/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class ARFLineNode: ARFNode {
    static let defaultColor: UIColor = UIColor.white
    private var line: SCNCylinder?
    
    private var fromPoint = SCNVector3()
    private var toPoint = SCNVector3()
    private var widthLine: CGFloat = 0.001
    
    var from: SCNVector3 {
        get {
            return fromPoint
        }
        set(pos) {
            if !fromPoint.isEqual(pos) {
                fromPoint = pos
                refresh()
            }
        }
    }
    
    var to: SCNVector3 {
        get {
            return toPoint
        }
        set(pos) {
            if !toPoint.isEqual(pos) {
                toPoint = pos
                refresh()
            }
        }
    }
    
    var width: CGFloat {
        get {
            return widthLine
        }
        set(w) {
            if widthLine != w {
                widthLine = w
                refresh()
            }
        }
    }
    
    public var color: UIColor {
        get {
            return line!.firstMaterial?.diffuse.contents as! UIColor
        }
        set {
            line!.firstMaterial?.diffuse.contents = newValue
            refresh()
        }
    }
    
    override public init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(from: SCNVector3, to: SCNVector3, width: CGFloat = 0.001) {
        super.init()
        fromPoint = from
        toPoint = to
        widthLine = width
        refresh()
    }
    
    deinit {
        
    }
    
    private func refresh() {
        let vec = to - from
        let l = vec.norma()
        
        //original vector of cylinder above 0,0,0
        let ov = SCNVector3(0, l/2.0, 0)
        
        //target vector, in new coordination
        let nv = vec / Float(2)
        
        // axis between two vector
        let av = (ov + nv) / 2
        
        //normalized axis vector
        let av_normalized = av/av.norma()
        
        let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = Float(av_normalized.x) // x' * sin(angle/2)
        let q2 = Float(av_normalized.y) // y' * sin(angle/2)
        let q3 = Float(av_normalized.z) // z' * sin(angle/2)
        
        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
        
        self.transform.m11 = r_m11
        self.transform.m12 = r_m12
        self.transform.m13 = r_m13
        self.transform.m14 = 0.0
        
        self.transform.m21 = r_m21
        self.transform.m22 = r_m22
        self.transform.m23 = r_m23
        self.transform.m24 = 0.0
        
        self.transform.m31 = r_m31
        self.transform.m32 = r_m32
        self.transform.m33 = r_m33
        self.transform.m34 = 0.0
        
        self.transform.m41 = (from.x + to.x) / 2.0
        self.transform.m42 = (from.y + to.y) / 2.0
        self.transform.m43 = (from.z + to.z) / 2.0
        self.transform.m44 = 1.0
        let oldColor = line?.firstMaterial?.diffuse.contents ?? ARFLineNode.defaultColor
        line = SCNCylinder(radius: width / 2, height: CGFloat(l))
        line?.firstMaterial?.diffuse.contents = oldColor
        self.geometry = line
    }
}
