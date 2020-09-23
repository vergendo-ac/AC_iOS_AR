//
//  UIImageView+adds.swift
//  myPlace
//
//  Created by Mac on 20/02/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

extension UIImageView {
    
    func addShadow() {
        let radius: CGFloat = self.frame.height / 2.0 //change it to .height if you need spread for height
        let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.1 * radius))
        //Change 2.1 to amount of spread you need and for height replace the code for height
        
        layer.cornerRadius = 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.5, height: 4.0)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 2
        clipsToBounds = false
        layer.shadowPath = shadowPath.cgPath
    }
}
