//
//  StickerModels.swift
//  myPlace
//
//  Created by Mac on 31.07.2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import CoreGraphics
import ARKit

public enum StickerModels {
    
    struct StickerShort {
        let urlPath: URL?
        let text: String?
    }
    
    public struct StickerData {
        let id: Int?
        let options: [String: String]
    }
    
    struct Node {
        let distance: Double?
        let id: Int?
        let points: [CGPoint]?
    }
    
    struct StickerNode {
        let id: Int
        let distantPoint: PointModels.DistantPoint
        let stickerData: StickerModels.StickerData
    }
    
    struct Sticker: Codable {
        let path: String?
        let sticker_text: String?
        let sticker_type: String?
        let created_by: String?
        let creation_date: String?
        let sticker_subtype: String?
        let description: String?
    }
    
    struct Projection: Codable {
        var points: [[Int]]
        var filename: String
        var nativePoints: [CGPoint]
        var offset: CGPoint
        var scale: CGFloat
        
        init(points: [CGPoint], offset: CGPoint = .zero, scale: CGFloat = 1.0) {
            self.nativePoints = points
            self.offset = offset
            self.scale = scale
            self.points = points.map {
                [Int(($0.x - offset.x) / scale), Int(($0.y - offset.y) / scale)]
            }
            self.filename = ""
        }

    }
    
    struct Placeholder: Codable {
        var projections: [Projection]
    }
    
    struct StickerModel {
        let stickerFrame: Dictionary<String, CGPoint>?
        let stickerOffset: CGPoint?
        let scaleCoeff: CGFloat?
        let sticker: Sticker
    }

    struct ObjectModel: Codable {
        let sticker: Sticker
        var placeholder: Placeholder
        
        mutating func add(filename: String, index: Int = 0) -> ObjectModel {
            self.placeholder.projections[index].filename = filename
            return self
        }
    }
    
    class ARCameraPose {
        let filename: String
        let cameraPose: simd_float4x4
        var anchorPose: simd_float4x4?
        let gravity: simd_double3?
        
        init(filename: String, cameraPose: simd_float4x4, anchorPose: simd_float4x4? = nil, gravity: simd_double3? = nil) {
            self.filename = filename
            self.cameraPose = cameraPose
            self.anchorPose = anchorPose
            self.gravity = gravity
        }
    }
}
