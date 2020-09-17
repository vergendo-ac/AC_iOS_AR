//
//  AppInfoHelper.swift
//  MyPlaceLibIOS
//
//  Created by Mac on 11.03.2020.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation
import UIKit

class AppInfoHelper {
    
    static let instance = AppInfoHelper()
    
    enum InfoType: String {
        case AppVersion
        case AppName
        case BundleId
        case BuildNumber
        case OSNameVersion
        case PhoneModel
        case BuildType
        case UUID
    }
    
    private var info: [String:String] = [:]
    
    init() {
        
        info[InfoType.AppVersion.rawValue] = Bundle.main.versionNumber
        info[InfoType.AppName.rawValue] = Bundle.main.appName
        info[InfoType.BundleId.rawValue] = Bundle.main.bundleId
        info[InfoType.BuildNumber.rawValue] = Bundle.main.buildNumber
        info[InfoType.OSNameVersion.rawValue] = {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            
            let osName: String = {
                #if os(iOS)
                return "iOS"
                #elseif os(watchOS)
                return "watchOS"
                #elseif os(tvOS)
                return "tvOS"
                #elseif os(macOS)
                return "OS X"
                #elseif os(Linux)
                return "Linux"
                #else
                return "Unknown"
                #endif
            }()
            
            return "\(osName) \(versionString)"
        }()
        info[InfoType.PhoneModel.rawValue] = UIDevice.modelName
        info[InfoType.BuildType.rawValue] = self.buildType()
        info[InfoType.UUID.rawValue] = UIDevice.current.identifierForVendor!.uuidString

    }
    
    func getAppInfo(for key: AppInfoHelper.InfoType, defaultValue: String? = nil) -> String {
        return self.info[key.rawValue] ?? (defaultValue ?? "")
    }
        
    private func buildType() -> String {
        #if DEBUG
        return "debug"
        #elseif RELEASE
        return "release"
        #else
        return "unknown_build_type"
        #endif
    }
    
}
