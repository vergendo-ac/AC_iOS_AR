//
//  Node3D.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 20/04/2019.
//  Copyright © 2019 Unit. All rights reserved.
//
import Foundation
//import SwiftyJSON
import ARKit

class Node3D: Equatable {
    var distance: Double?
    var id: String
    var points: [simd_float3] = []
    
    init(json: JSON) {
        distance = json["distance"].double
        id = json["id"].stringValue
        points = []
        
        if let pts = json["points"].arrayObject as? [[Double]] {
            for pt in pts {
                points.append(simd_float3(x: Float(pt[0]), y: Float(pt[1]), z: Float(pt[2])))
            }
        }
    }
    
    init(id: String, points: [simd_float3]) {
        self.id = id
        self.points = points
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func == (lhs: Node3D, rhs: Node3D) -> Bool {
        return lhs.id == rhs.id
    }
    
}
