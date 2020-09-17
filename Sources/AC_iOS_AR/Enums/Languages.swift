//
//  Languages.swift
//  myPlace
//
//  Created by Mac on 01/03/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation

class Languages {
    
    public static var currentLanguage: Languages.types = {
        if NSLocalizedString("lang", comment: "") == "ru" {
            return types.ru
        } else {
            return types.en
        }
    }()
    
    public enum types {
        case ru
        case en
    }
    
}
