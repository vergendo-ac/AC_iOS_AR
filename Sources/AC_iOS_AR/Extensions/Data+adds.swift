//
//  Data+adds.swift
//  myPlace
//
//  Created by Mac on 03/12/2018.
//  Copyright © 2018 Unit. All rights reserved.
//

import UIKit

extension Data {
    
    public func getMetaData() -> NSDictionary? {
        //http://metapicz.com/#landing
        //get metadata from source
        if let source = CGImageSourceCreateWithData(self as CFData, nil) {
            if let dictionary = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) {
                return NSDictionary(dictionary: dictionary)
            }
            //if let metadata = NSMutableDictionary(dictionary: CGImageSourceCopyPropertiesAtIndex(source, 0, nil)!)
            //return metadata
        }

        return nil
    }
    
    public func addMetaData(metadata: NSDictionary) -> Data {
        //add metadata
        let source = CGImageSourceCreateWithData(self as CFData, nil)!
        let UTI: CFString = CGImageSourceGetType(source)!
        let dest_data = NSMutableData()
        let destination: CGImageDestination = CGImageDestinationCreateWithData(dest_data as CFMutableData, UTI, 1, nil)!
        CGImageDestinationAddImageFromSource(destination, source, 0, metadata)
        CGImageDestinationFinalize(destination)
        return dest_data as Data
    }
    
    public func convertToJPEG() -> Data? {
        let jpegData = UIImage(data: self)?.jpegData(compressionQuality: 1.0)

        if let metadata = self.getMetaData() {
            return jpegData?.addMetaData(metadata: metadata)
        } else {
            return jpegData
        }

    }
    
    public func convertHEICtoJPEG() -> Data? {
        let isHeic2Jpeg: Bool = UserDefaults.heic2Jpeg ?? true
        return (isHeic2Jpeg) ? self.convertToJPEG() : self
    }
    
}
