//
// InlineObject2.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation


public struct InlineObject2: Codable {

    public var description: ImageDescription
    /** A JPEG-encoded image */
    public var image: URL
    public var hint: LocalizationHint?

    public init(description: ImageDescription, image: URL, hint: LocalizationHint? = nil) {
        self.description = description
        self.image = image
        self.hint = hint
    }

}

