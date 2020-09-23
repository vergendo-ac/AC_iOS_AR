//
//  RatingCircleView.swift
//  myPlace
//
//  Created by Mac on 20/02/2019.
//  Copyright © 2019 Unit. All rights reserved.
//
//https://medium.com/@jacks205/lets-create-a-custom-uiview-circle-indicator-in-swift-ec5a2b993dec
//

import UIKit

import UIKit

class RatingCircleViewT2: UIView {
    
    fileprivate var startAngle: Int = 90
    fileprivate var endAngle: Int = 90 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    fileprivate var index: Int = 10
    var rcolor: CategoryPin = .other {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var stickerView = StickerSceneView()
    
    override func draw(_ rect: CGRect) {
        
        //In drawRect:
        //Base circle
        UIColor.black.setFill()
        
        let outerPath = UIBezierPath(ovalIn: rect)
        outerPath.fill()
        //self.frame isn’t defined yet, so we can’t use self.center
        //let viewCenter = CGPoint(x: rect.width / 2, y: rect.height / 2)
        
        //Center circle
        self.rcolor.color.setFill()
        let centerPath = UIBezierPath(ovalIn: rect.insetBy(dx: rect.width * 0.2 / 2, dy: rect.height * 0.2 / 2))
        centerPath.fill()
        
        //Semi Circles
        let radius = rect.width * 0.3
        
        UIColor.black.setFill()
        let midPath = UIBezierPath()
        midPath.move(to: center)
        midPath.addArc(withCenter: center, radius: CGFloat(radius), startAngle: CGFloat(startAngle.degrees2radians), endAngle: CGFloat(endAngle.degrees2radians), clockwise: true)
        midPath.close()
        midPath.fill()
        
    }
    
    public func setType(color: CategoryPin) {
        self.rcolor = color
    }
    
    public func setAngles(with fraction: Float, index: Int) {
        self.index = index
        if (fraction < 0.0 || fraction > 1.0) {
            print("RatingCircleView: WRONG fraction value = \(fraction)")
        } else {
            self.endAngle = Int(fraction * 360) + 90
            //self.setNeedsDisplay()
        }
    }
    
}
