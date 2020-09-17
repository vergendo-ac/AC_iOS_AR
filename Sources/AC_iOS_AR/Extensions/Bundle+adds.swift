//
//  Bundle+adds.swift
//  Developer
//
//  Created by Mac on 23.08.2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import Foundation

extension Bundle {
    
    var appName: String {
        return infoDictionary?["CFBundleName"] as! String
    }
    
    var bundleId: String {
        return bundleIdentifier!
    }
    
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
    
}
