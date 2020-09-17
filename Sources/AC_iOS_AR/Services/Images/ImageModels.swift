//
//  ImagesModels.swift
//  myPlace
//
//  Created by Mac on 31.07.2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import CoreGraphics

enum ImageModels {
    
    enum ImageSource: String {
        case GDDoors = "iosDrsGd_"
        case GDUser = "iosUsrGd_"
        case PhotoCamera = "iosImage"
        case PhoneGallery = "iosGal_"
        case ARCamera = "iosArImage"
    }
    
    struct Image {
        let data: Data?
        let size: CGSize?
        var filename: String?
        var localID: String?
        
        init(data: Data?, filename: String?, localID: String? = nil, size: CGSize? = nil) {
            self.data = data
            self.filename = filename
            self.localID = localID
            self.size = size
        }
        
        mutating func setID(with val: String) -> ImageModels.Image {
            self.localID = val
            return self
        }
        mutating func setName(with maybeNewName: String?) -> ImageModels.Image {
            if let newName = maybeNewName {
                self.filename = newName
            }
            return self
        }
    }
    
}
