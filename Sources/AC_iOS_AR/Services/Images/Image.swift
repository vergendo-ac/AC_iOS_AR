//
//  Images.swift
//  myPlace
//
//  Created by Mac on 31.07.2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import CoreGraphics
import ImageIO
import UIKit

class Image {
    
    //MARK: Global
    
    static let sharedInstance = Image()
    
    func doImageDataRequest(image: ImageModels.Image?, completion: @escaping (ImageModels.Image?, NetModels.StatusData?) -> Swift.Void) {
        
        //do we have data?
        guard let data = image?.data else {
            completion(nil, NetModels.StatusData(alert: AlertMessage(title: "No image data", message: "Image data needed")))
            return
        }
        
        //size check 100 kilobytes, maybe more - check
        // проверить размер кадров день-ночь
        //check image brightness with EXIF
        
        /*guard self.checkBrightness(data: data, level: 0.0) else {
         completion(nil, AlertMessage(title: "Image too dark", message: ""), NiceError.Image.UFO)
         return
        }*/
        
        //check data size
        guard (data.count / 1024 > 100) else {
            
            completion(nil, NetModels.StatusData(alert: AlertMessage(title: "Image too small", message: "Have only \(data.count) bytes")))
            return
        }
        
        //perhaps we have not jpeg data
        var nonJpegData: Data? = data
        var rightFilename: String? = image?.filename
        
        //check image name & extension
        if let filename = image?.filename, let filenameExt = filename.divideLast(ch: ".") {
            let name = filenameExt.0
            let ext = filenameExt.1
            
            if !(ext == "jpg" || ext == "jpeg") {
                nonJpegData = data.convertHEICtoJPEG()
                rightFilename = name + ".jpg"
            } else {
                rightFilename = filename
            }
        }
        
        //print("rightFilename = \(rightFilename)")
        
        //try to get jpeg data
        guard let jpegData = nonJpegData else {
            completion(nil, NetModels.StatusData(alert: AlertMessage(title: "Non jpeg image data", message: "Jpeg image data needed")))
            return
        }
        
        //print(" Image metadata: \(jpegData.getMetaData())")
        
        let checkMimeTypeResult = self.checkMimeType(data: jpegData as CFData)
        
        if checkMimeTypeResult.0 {
            let imageSize: CGSize? = UIImage(data: jpegData)?.size
            let isUseGNSSdata: Bool = UserDefaults.useGNSSdata ?? true
            guard let metaData = jpegData.getMetaData() else {
                completion(nil, NetModels.StatusData(alert: AlertMessage(title: "Non jpeg image data", message: "Jpeg image data needed")))
                return
            }
            
            let oldMetadata = NSMutableDictionary(dictionary: metaData)
            let noGnssDataError = (oldMetadata[kCGImagePropertyGPSDictionary] == nil) ? AlertMessage(title: "No GNSS data", message: "GNSS data needed") : nil
            
            if !isUseGNSSdata, let metadata = jpegData.getMetaData() {
                //get data from source
                let oldMetadata = NSMutableDictionary(dictionary: metadata)
                //print("Old metadata: \(oldMetadata)")
                oldMetadata.setObject(kCFNull, forKey: kCGImagePropertyGPSDictionary as! NSCopying)
                //save new metadata, without GPS
                let dest_data = jpegData.addMetaData(metadata: oldMetadata)
                
                completion(ImageModels.Image(data: dest_data, filename: rightFilename, size: imageSize), NetModels.StatusData(alert: noGnssDataError))
            } else {
                completion(ImageModels.Image(data: jpegData, filename: rightFilename, size: imageSize), NetModels.StatusData(alert: noGnssDataError))
            }
        } else {
            completion(nil, NetModels.StatusData(alert: AlertMessage(title: "WRONG image mimeType", message: "Got \(checkMimeTypeResult.1) \n Sorry, only JPEG images are allowed for now.")))
        }
        
    }
    
    func getUIImage(from imageModel: ImageModels.Image?) -> UIImage? {
        if let data = imageModel?.data {
            return UIImage(data: data)
        }
        return nil
    }
    
    func normalizeImageNamesAndSort(images: [ImageModels.Image], completion: @escaping ([ImageModels.Image]) -> Void) {
        var updatedImages: [ImageModels.Image] = []
        for i in 0 ... (images.count-1) {
            updatedImages.append(ImageModels.Image(
                data: images[i].data,
                filename: "\(ImageModels.ImageSource.PhotoCamera.rawValue)\(i+1).jpg",
                localID: images[i].localID)
            )
        }
        completion(updatedImages.sorted(by: { (img1, img2) -> Bool in
            img1.filename! < img2.filename!
        }) )
    }
    
    //MARK: Private
    private func checkBrightness(data: Data, level: Double) -> Bool {
        var dataBrightness: Double = level + 1
        if let exifDic: NSDictionary = data.getMetaData()?.value(forKey: kCGImagePropertyExifDictionary as String) as? NSDictionary,
            let brightness = exifDic.value(forKey: kCGImagePropertyExifBrightnessValue as String) as? Double {
            dataBrightness = brightness
            //print(dataBrightness)
        }
        return dataBrightness > level
    }
    
    private func checkMimeType(data: CFData) -> (Bool, String) {
        let imgSrc = CGImageSourceCreateWithData(data, nil)
        if let uti = CGImageSourceGetType(imgSrc!) {
            let utiS = uti as String
            return (utiS == "public.jpeg", utiS)
        } else {
            return (false, "Unknown mimeType")
        }
    }
    
}
