//
//  DesignModel.swift
//  myPlace
//
//  Created by Mac on 22/02/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation

enum Design {
    
    struct Gradient {
        let firstColor: String
        let secondColor: String
        let angle: Int
    }
    
    struct Shadow {
        let color: String
        let transparency: Float // 0..1
    }
    
    struct Font {
        let name: String
        let size: Int
    }
    
    struct Text {
        let text: String
        let font: Design.Font
        let color: String
    }
    
    struct Button {
        let gradient: Design.Gradient
        let text: Design.Text
    }

}
