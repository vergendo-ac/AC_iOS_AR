//
//  UIColor+additions.swift
//  myPlace
//
//  Created by Mac on 26/10/2018.
//  Copyright © 2018 Unit. All rights reserved.
//

import UIKit


extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }

    var rgbaTuple: (CGFloat, CGFloat, CGFloat, CGFloat, Bool) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        let res = self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha, res)
    }
    
    static func random() -> UIColor {
        return UIColor(red:   .random1(),
                       green: .random1(),
                       blue:  .random1(),
                       alpha: 1.0)
    }

    
    //MARK: DARK MODE
    //TODO: Test
    static func myColor() -> UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                // the color can be from your own color config struct as well.
                return trait.userInterfaceStyle == .dark ? UIColor.darkGray : UIColor.orange
            }
        }
        else { return UIColor.orange }
    }
}
