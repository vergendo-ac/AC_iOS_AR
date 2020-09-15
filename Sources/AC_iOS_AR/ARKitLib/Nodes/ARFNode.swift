//
//  ARFNode.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 30/07/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class ARFNode: SCNNode {
    
    func setPivot() {
        let minVec = boundingBox.min
        let maxVec = boundingBox.max
        let bound = SCNVector3Make(maxVec.x - minVec.x, maxVec.y - minVec.y, maxVec.z - minVec.z)
        pivot = SCNMatrix4MakeTranslation(minVec.x + (bound.x / 2), minVec.y + (bound.y / 2), 0)
    }
}
