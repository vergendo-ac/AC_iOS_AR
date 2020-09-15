//
//  ARFSphereNode.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 30/07/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class ARFSphereNode: ARFNode {
    let scn = SCNSphere()
    static let defaultColor: UIColor = UIColor.green
    
    override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(radius: CGFloat) {
        super.init()
        scn.radius = radius
        scn.firstMaterial?.isDoubleSided = true
        scn.firstMaterial?.diffuse.contents = ARFSphereNode.defaultColor
        self.geometry = scn
    }
    
    deinit {
        
    }
    
    public var color: UIColor {
        get {
            return scn.firstMaterial?.diffuse.contents as! UIColor
        }
        set {
            scn.firstMaterial?.diffuse.contents = newValue
        }
    }
    
    public var radius: CGFloat {
        get {
            return scn.radius
        }
        set {
            scn.radius = newValue
        }
    }
}
