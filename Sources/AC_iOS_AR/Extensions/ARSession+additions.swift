//
//  ARSession+additions.swift
//  myPlace
//
//  Created by Mac on 06/11/2018.
//  Copyright © 2018 Unit. All rights reserved.
//

import ARKit

extension ARSession {
    
    /// Returns The Status Of The Current ARSession
    ///
    /// - Returns: String
    func sessionStatus() -> String? {
        
        //1. Get The Current Frame
        guard let frame = self.currentFrame else { return nil }
        
        var status = "Preparing Device.."
        
        //1. Return The Current Tracking State & Lighting Conditions
        switch frame.camera.trackingState {
            
        case .normal:                                                   status = "Normal"
        case .notAvailable:                                             status = "Tracking Unavailable"
        case .limited(.excessiveMotion):                                status = "Please Slow Your Movement"
        case .limited(.insufficientFeatures):                           status = "Try To Point At A Flat Surface"
        case .limited(.initializing):                                   status = "Initializing"
        case .limited(.relocalizing):                                   status = "Relocalizing"
        default:                                                        status = "Unknown AR camera status"
            
        }
        
        guard let lightEstimate = frame.lightEstimate?.ambientIntensity else { return nil }
        
        if lightEstimate < 100 { status = "Lighting Is Too Dark" }
        
        return status
        
    }
    
}
