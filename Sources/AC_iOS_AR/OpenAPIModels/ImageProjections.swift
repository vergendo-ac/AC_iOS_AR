//
// ImageProjections.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation


public struct ImageProjections: Codable {

    public var points: [Vector2i]
    public var filename: String

    public init(points: [Vector2i], filename: String) {
        self.points = points
        self.filename = filename
    }

}
