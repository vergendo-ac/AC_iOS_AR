//
//  CGFloat+adds.swift
//  MyPlaceLibIOS
//
//  Created by Mac on 04.10.2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    static func random1() -> CGFloat {
        return CGFloat.random(in: 0...1)
    }
}
