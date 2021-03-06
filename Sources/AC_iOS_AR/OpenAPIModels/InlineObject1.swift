//
// InlineObject1.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation


public struct InlineObject1: Codable {

    public var description: ObjectWithMarkedImage
    /** A JPEG-encoded image, must include GPS data in EXIF tags */
    public var image: URL

    public init(description: ObjectWithMarkedImage, image: URL) {
        self.description = description
        self.image = image
    }

}

