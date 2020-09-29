//
// ImageDescription.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

/** Describes gps position and camera parameters */
public struct ImageDescription: Codable {

    public enum Rotation: Int, Codable, CaseIterable {
        case _0 = 0
        case _90 = 90
        case _180 = 180
        case _270 = 270
    }
    public var gps: ImageDescriptionGps
    public var intrinsics: CameraIntrinsics?
    public var focalLengthIn35mmFilm: Int?
    public var mirrored: Bool? = false
    /** Clockwise camera rotation */
    public var rotation: Rotation? = ._0

    public init(gps: ImageDescriptionGps, intrinsics: CameraIntrinsics? = nil, focalLengthIn35mmFilm: Int? = nil, mirrored: Bool? = nil, rotation: Rotation? = nil) {
        self.gps = gps
        self.intrinsics = intrinsics
        self.focalLengthIn35mmFilm = focalLengthIn35mmFilm
        self.mirrored = mirrored
        self.rotation = rotation
    }

    public enum CodingKeys: String, CodingKey, CaseIterable { 
        case gps
        case intrinsics
        case focalLengthIn35mmFilm = "focal_length_in_35mm_film"
        case mirrored
        case rotation
    }

}
