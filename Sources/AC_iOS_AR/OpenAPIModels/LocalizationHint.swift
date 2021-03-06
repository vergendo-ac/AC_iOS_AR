//
// LocalizationHint.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

/** List of reconstruction identifiers. The service will perform localization sequentially in each reconstruction according to the order specified in the list until the first successful result is obtained. If hint_only is true, the service will localize only in the specified reconstructions. If hint_only is false, the service will continue localization attempts in the nearest reconstructions */
public struct LocalizationHint: Codable {

    public var reconstructions: [Int]
    public var hintOnly: Bool? = false

    public init(reconstructions: [Int], hintOnly: Bool? = nil) {
        self.reconstructions = reconstructions
        self.hintOnly = hintOnly
    }

    public enum CodingKeys: String, CodingKey, CaseIterable { 
        case reconstructions
        case hintOnly = "hint_only"
    }

}

