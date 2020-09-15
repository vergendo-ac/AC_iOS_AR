//
//  PoseMetadata.swift
//  Developer
//
//  Created by Andrei Okoneshnikov on 24/09/2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import Foundation
import ARKit
//import SwiftyJSON

struct ArCameraIntrinsics {
    let fx: Float
    let fy: Float
    let cx: Float
    let cy: Float
}

class PoseMetadata {
    let fileName: String
    let arkitPose: double4x4
    var anchorPose: double4x4?
    let featurePoints: [double3]
    var startHeading: Double?
    var endHeading: Double?
    var startGravity: double3?
    var endGravity: double3?
    var intrinsics: ArCameraIntrinsics?
    
    init(fileName: String, featurePoints: [double3], arkitPose: double4x4, anchorPose: double4x4? = nil, intrinsics: ArCameraIntrinsics? = nil) {
        self.fileName = fileName
        self.arkitPose = arkitPose
        self.anchorPose = anchorPose
        self.featurePoints = featurePoints
        self.intrinsics = intrinsics
    }
    
    //WARNING! ONLY arkitPose
    init?(jsonString: String) {
        let json = JSON(parseJSON: jsonString)
        guard !json.isEmpty, let pose = json["arkitPose"].array,
                pose.count == 16, pose[0].double != nil else {
            return nil
        }
        
        var cols = [simd_double4(), simd_double4(), simd_double4(), simd_double4()]
        for i in 0..<pose.count {
            cols[i / 4][i % 4] = pose[i].doubleValue
        }
        arkitPose = double4x4(columns:(cols[0], cols[1], cols[2], cols[3]))
        fileName = ""
        featurePoints = []
        
        if let items = json["intrinsics"].array, items.count == 4 {
            self.intrinsics = ArCameraIntrinsics(
                fx: items[0].floatValue,
                fy: items[1].floatValue,
                cx: items[2].floatValue,
                cy: items[3].floatValue
            )
        }
    }
    
    func asJson() -> JSON {
        var metadata: [String: Any] = [:]
        
        if let cols = anchorPose?.columns {
            metadata["anchorPose"] = [
                cols.0.x, cols.0.y, cols.0.z, cols.0.w,
                cols.1.x, cols.1.y, cols.1.z, cols.1.w,
                cols.2.x, cols.2.y, cols.2.z, cols.2.w,
                cols.3.x, cols.3.y, cols.3.z, cols.3.w]
        }
        
        let arkitCols = arkitPose.columns
        metadata["arkitPose"] = [
            arkitCols.0.x, arkitCols.0.y, arkitCols.0.z, arkitCols.0.w,
            arkitCols.1.x, arkitCols.1.y, arkitCols.1.z, arkitCols.1.w,
            arkitCols.2.x, arkitCols.2.y, arkitCols.2.z, arkitCols.2.w,
            arkitCols.3.x, arkitCols.3.y, arkitCols.3.z, arkitCols.3.w]
        
        /*
         var points: [[Double]] = []
         
         for pt in info.featurePoints {
         points.append([pt.x, pt.y, pt.z])
         }
         
         metadata["featurePoints"] = points
         */
        
        if let startHeading = startHeading {
            metadata["startHeading"] = startHeading
        }
        
        if let endHeading = endHeading {
            metadata["endHeading"] = endHeading
        }
        
        if let gravity = startGravity {
            metadata["startGravity"] = [gravity.x, gravity.y, gravity.z]
        }
        
        if let gravity = endGravity {
            metadata["endGravity"] = [gravity.x, gravity.y, gravity.z]
        }
        
        if let items = intrinsics {
            metadata["intrinsics"] = [items.fx, items.fy, items.cx, items.cy]
        }
        
        return JSON(metadata)
    }
}
