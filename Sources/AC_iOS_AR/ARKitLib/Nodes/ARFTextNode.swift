//
//  ARFTextNode.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 30/07/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class ARFTextNode: ARFNode {
    static let defaultFontSize: CGFloat = 0.45
    static let defaultFont: UIFont = UIFont.systemFont(ofSize: defaultFontSize)
    static let defaultColor: UIColor = UIColor.green
    static let defaultDepth: CGFloat = 0.03
    static let defaultFlatness: CGFloat = 0.3
    let scnText = SCNText()
    
    var text: String {
        get {
            return scnText.string as! String
        }
        
        set {
            scnText.string = newValue
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(text: String, name: String? = nil) {
        super.init()
        scnText.string = text
        
        scnText.font = ARFTextNode.defaultFont
        scnText.extrusionDepth = ARFTextNode.defaultDepth
        scnText.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        scnText.truncationMode = CATextLayerTruncationMode.end.rawValue
        scnText.firstMaterial?.isDoubleSided = true
        scnText.firstMaterial?.diffuse.contents = ARFTextNode.defaultColor
        scnText.flatness = ARFTextNode.defaultFlatness
        scnText.isWrapped = true
        
        if name != nil {
            self.name = name
        }
        
        self.geometry = scnText
        
        initTransform()
    }
    
    fileprivate func initTransform() {
        self.transform = SCNMatrix4Identity
        self.scale = SCNVector3Make(0.05, 0.05, 0.05)
    }
    
    deinit {
        
    }
    
    public var color: UIColor {
        get {
            return scnText.firstMaterial?.diffuse.contents as! UIColor
        }
        set {
            scnText.firstMaterial?.diffuse.contents = newValue
        }
    }
    
    public var font: UIFont {
        get {
            return scnText.font
        }
        set {
            scnText.font = newValue
        }
    }
}
