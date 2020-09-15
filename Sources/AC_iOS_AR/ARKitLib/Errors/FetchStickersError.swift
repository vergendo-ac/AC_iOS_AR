//
//  FetchStickersError.swift
//  Developer
//
//  Created by Andrei Okoneshnikov on 26/07/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
//import SwiftyJSON

enum FetchStickersError: Error {
    case unknown
    case jsonError(code: Int?, message: String?)
    case serverError(code: Int?, message: String?)
    
    var message: String? {
        switch self {
        case .jsonError(_, let message), .serverError(_, let message):
            return message
        default:
            return nil
        }
    }
    
    var code: Int? {
        switch self {
        case .jsonError(let code, _), .serverError(let code, _):
            return code
        default:
            return nil
        }
    }
    
    static func parseError(json: JSON) -> Error? {
        if !JSONSerialization.isValidJSONObject(json.rawValue) {
            return FetchStickersError.serverError(code: 0, message: "Invalid json object")
        } else {
            if let status = json["status"].dictionary {
                let code = status["code"]?.int
                let message = status["message"]?.string
                if code != 0 {
                    return FetchStickersError.serverError(code: code, message: message)
                }
            }
        }
        return nil
    }
}
