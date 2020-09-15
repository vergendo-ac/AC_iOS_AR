//
//  ARFPlaneNode.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 30/07/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class ARFPlaneNode: ARFNode {
    private let scn = SCNPlane(width: 0, height: 0)
    static let defaultColor: UIColor = UIColor.clear
    static let defTransparency: CGFloat = 1.0
    
    override init() {
        super.init()
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    init(width: CGFloat, height: CGFloat, name: String? = nil) {
        super.init()
        scn.width = width
        scn.height = height
        if name != nil {
            self.name = name
        }
        initialize()
    }
    
    deinit {
        
    }
    
    private func initialize()  {
        scn.firstMaterial?.isDoubleSided = true
        scn.firstMaterial?.diffuse.contents = ARFPlaneNode.defaultColor
        scn.firstMaterial?.transparency =  ARFPlaneNode.defTransparency
        self.geometry = scn
    }
    
    var width: CGFloat {
        get {
            return scn.width
        }
        set {
            scn.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return scn.height
        }
        set {
            scn.height = newValue
        }
    }
    
    var transparency: CGFloat {
        get {
            return scn.firstMaterial!.transparency
        }
        set {
            scn.firstMaterial!.transparency = newValue
        }
    }
    
    public var color: UIColor {
        get {
            return scn.firstMaterial?.diffuse.contents as! UIColor
        }
        set {
            scn.firstMaterial?.diffuse.contents = newValue
        }
    }
}
