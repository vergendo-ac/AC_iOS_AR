//
//  UIImage+additions.swift
//  myPlace
//
//  Created by Mac on 06/11/2018.
//  Copyright © 2018 Unit. All rights reserved.
//

import UIKit
//import Alamofire
//import AlamofireImage
import CoreImage
import VideoToolbox

extension UIImage {
    
    //TODO: how to wait till image loading??? Now everytime nil is sending.
    /*public convenience init?(url: URL?) {
        
        if let url = url {

            var cgImage: CGImage? = nil
            
            Alamofire.request(url.absoluteString).responseImage { response in
                cgImage = response.result.value?.cgImage
                
            }

            guard let image = cgImage else { return nil }
            self.init(cgImage: image)
            
        } else {
            return nil
        }
        
    }*/
    
    func withSize(_ size:CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resizedImage(for size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    public convenience init?(maybeData: Data?) {
        guard let data = maybeData else {
            return nil
        }
        self.init(data: data)
    }
    
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        if let cgi = cgImage {
            self.init(cgImage: cgi)
        } else {
            return nil
        }
    }
    
    func crop(rect: CGRect) -> UIImage {
        let cgimage = self.cgImage!
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
    
    func perspectiveCorrection(topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint) -> UIImage? {
        let ciImage = CIImage(image: self)!
        return UIImage.perspectiveCorrection(ciImage: ciImage, topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft, size: size)
    }
    
    static func perspectiveCorrection(ciImage: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint, size: CGSize) -> UIImage? {
        
        func cartesian(point:CGPoint, size:CGSize) -> CGPoint {
            return CGPoint(x: point.x, y: size.height - point.y)
        }
        
        let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")!
        perspectiveCorrection.setValue(CIVector(cgPoint: cartesian(point: topLeft, size: size)),
                                       forKey: "inputTopLeft")
        perspectiveCorrection.setValue(CIVector(cgPoint: cartesian(point: topRight, size: size)),
                                       forKey: "inputTopRight")
        perspectiveCorrection.setValue(CIVector(cgPoint: cartesian(point: bottomRight, size: size)),
                                       forKey: "inputBottomRight")
        perspectiveCorrection.setValue(CIVector(cgPoint: cartesian(point: bottomLeft, size: size)),
                                       forKey: "inputBottomLeft")
        perspectiveCorrection.setValue(ciImage,
                                       forKey: kCIInputImageKey)
        
        if let output = perspectiveCorrection.outputImage {
            let context = CIContext(options: nil)
            if let cgImage = context.createCGImage(output, from: output.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
    
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}
