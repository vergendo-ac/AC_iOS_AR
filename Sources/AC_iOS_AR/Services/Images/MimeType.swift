//
//  MimeType.swift
//  myPlace
//
//  Created by Mac on 30/11/2018.
//  Copyright © 2018 Unit. All rights reserved.
//

import Foundation

/*
 //https://ru.wikipedia.org/wiki/%D0%A1%D0%BF%D0%B8%D1%81%D0%BE%D0%BA_MIME-%D1%82%D0%B8%D0%BF%D0%BE%D0%B2
 image/gif: GIF(RFC 2045 и RFC 2046)
 image/jpeg: JPEG (RFC 2045 и RFC 2046)
 image/pjpeg: JPEG[8]
 image/png: Portable Network Graphics[9](RFC 2083)
 image/svg+xml: SVG[10]
 image/tiff: TIFF(RFC 3302)
 image/vnd.microsoft.icon: ICO[11]
 image/vnd.wap.wbmp: WBMP
 image/webp: WebP
 */

//"application/vnd.google-apps.document"
//"application/vnd.google-apps.spreadsheet"
//"application/vnd.openxmlformats-officedocument.wordprocessingml.document"
//"application/vnd.google-apps.form"
//"application/vnd.google-apps.drawing"
//"application/java-archive"
//"application/vnd.google-apps.presentation"
//"application/json"
//"application/gpx+xml""

public class MimeType {
    
    public enum types: String {
        case googleFolder = "application/vnd.google-apps.folder"
        case jpeg = "image/jpeg"
        case png = "image/png"
        case vbmp = "image/vnd.wap.wbmp"
        case bmp = "image/bmp"
        case tiff = "image/tiff"
        case icon = "image/vnd.microsoft.icon"
        case gif = "image/gif"
    }
    
    public static let imageTypes: [String] = ["image/bmp", "image/gif", "image/jpeg", "image/pjpeg", "image/png", "image/tiff", "image/vnd.microsoft.icon", "image/vnd.wap.wbmp", "image/webp"]
    
    public static func approveImage(mimeTypeO : String?) -> Bool {
        if let mimeType = mimeTypeO {
            return  imageTypes.contains(mimeType)
        }
        return false
    }

}

