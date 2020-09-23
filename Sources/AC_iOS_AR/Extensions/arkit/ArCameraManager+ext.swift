//
//  ArCameraManager+ext.swift
//  YaPlace
//
//  Created by Andrei Okoneshnikov on 24.07.2020.
//  Copyright © 2020 SKZ. All rights reserved.
//

import Foundation
import UIKit

extension ArCameraManager {
    func clearArkitSceneWithContentStickers(clearAnchors: Bool = true) {
        if let childs = arKitSceneView?.scene.rootNode.childNodes {
            for child in childs {
                if let node = child as? ARFVideoNode {
                    node.cleanup()
                    node.removeFromParentNode()
                }
            }
        }
        
        self.clearArkitScene(clearAnchors: clearAnchors)
    }
    
    func clearArNodes(clearAnchors: Bool = true, clearContent: Bool = true) {
        if let childs = arKitSceneView?.scene.rootNode.childNodes {
            for child in childs {
                if child is ARFVideoNode, !clearContent {
                    continue
                }
                
                if child is ARFNode {
                    child.removeFromParentNode()
                }
            }
        }
        
        // remove anchors
        if clearAnchors {
            for anchor in arKitSceneView?.session.currentFrame?.anchors ?? [] {
                if !(anchor is ArCameraPoseAnchor) {
                    arKitSceneView?.session.remove(anchor: anchor)
                }
            }
        }
        
        self.clearDebugInfo()
    }
    
    func arSnapshot() -> UIImage? {
        guard let arkitView = arKitSceneView else {
            return nil
        }
        
        let fixImage = arkitView.snapshot()
        return fixImage
    }
    
}
