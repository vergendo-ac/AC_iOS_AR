//
//  Sticker.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 20/04/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import SwiftyJSON
import ARKit

class StickerAR {
    var id: String
    var path: String
    var text: String
    
    init(json: JSON) {
        id = json["sticker_id"].stringValue
        path = json["path"].stringValue
        text = json["sticker_text"].stringValue
    }
}
