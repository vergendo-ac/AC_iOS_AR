//
//  UserDefaults+settings.swift
//  YaPlace
//
//  Created by Andrei Okoneshnikov on 25.02.2020.
//  Copyright © 2020 SKZ. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    private enum SettingsKeys {
        static let ArStatusEnabled = "ar_status_enabled"
        static let ManualRestartArsEnabled = "ar_session_manual_restart"
        static let RestartArsLimitValue = "ar_restart_ars_limit"
        static let ManualLocalizationEnabled = "ar_manual_localization"
        static let ArPlaneMaxDistanceValue = "ar_plane_max_disance"
        static let ArAnimationDurationValue = "ar_animation_duration"
        static let ArKfsDurationValue = "ar_kfs_duration"
        static let ArImageAnchorEnabled = "ar_image_anchor"
        static let ArHitTestTypeValue = "ar_hit_test_type"
        static let ArPinMaxDistanceValue = "ar_pin_max_distance"
        static let ArStickerDistanceEnabled = "ar_sticker_distance_enabled"
        static let ArHeadingAlignEnabled = "ar_heading_align_enabled"
    }
    
    static var arStatusEnabled: Bool? {
        get {
            if standard.string(forKey: SettingsKeys.ArStatusEnabled) == nil {
                return nil
            } else {
                return UserDefaults.standard.bool(forKey: SettingsKeys.ArStatusEnabled)
            }
        }
        set(v) {
            standard.set(v, forKey: SettingsKeys.ArStatusEnabled)
        }
    }
    
    static var manualRestartArsEnabled: Bool? {
        get {
            if standard.string(forKey: SettingsKeys.ManualRestartArsEnabled) == nil {
                return nil
            } else {
                return UserDefaults.standard.bool(forKey: SettingsKeys.ManualRestartArsEnabled)
            }
        }
        set(v) {
            standard.set(v, forKey: SettingsKeys.ManualRestartArsEnabled)
        }
    }
    
    static var manualLocalizationEnabled: Bool? {
        get {
            if standard.string(forKey: SettingsKeys.ManualLocalizationEnabled) == nil {
                return nil
            } else {
                return UserDefaults.standard.bool(forKey: SettingsKeys.ManualLocalizationEnabled)
            }
        }
        set(v) {
            standard.set(v, forKey: SettingsKeys.ManualLocalizationEnabled)
        }
    }
    
    static var restartArsLimitValue: Float? {
        get {
            if standard.string(forKey: SettingsKeys.RestartArsLimitValue) == nil {
                return nil
            } else {
                return standard.float(forKey: SettingsKeys.RestartArsLimitValue)
            }
        }
        set(v) {
            standard.set(v, forKey: SettingsKeys.RestartArsLimitValue)
        }
    }
    
    static var arPlaneMaxDistanceValue: Float? {
        get {
            if standard.string(forKey: SettingsKeys.ArPlaneMaxDistanceValue) == nil {
                return nil
            } else {
                return standard.float(forKey: SettingsKeys.ArPlaneMaxDistanceValue)
            }
        }
        set(v) {
            standard.set(v, forKey: SettingsKeys.ArPlaneMaxDistanceValue)
        }
    }
    
    static var arAnimationDurationValue: Float? {
        get {
            if standard.string(forKey: SettingsKeys.ArAnimationDurationValue) == nil {
                return nil
            } else {
                return standard.float(forKey: SettingsKeys.ArAnimationDurationValue)
            }
        }
        set(v) {
            standard.set(v, forKey: SettingsKeys.ArAnimationDurationValue)
        }
    }
    
    static var arKfsDurationValue: Float? {
        get {
            if standard.string(forKey: SettingsKeys.ArKfsDurationValue) == nil {
                return nil
            } else {
                return standard.float(forKey: SettingsKeys.ArKfsDurationValue)
            }
        }
        set(v) {
            standard.set(v, forKey: SettingsKeys.ArKfsDurationValue)
        }
    }
    
    static var arImageAnchorEnabled: Bool? {
        get {
            if standard.string(forKey: SettingsKeys.ArImageAnchorEnabled) == nil {
                return nil
            } else {
                return UserDefaults.standard.bool(forKey: SettingsKeys.ArImageAnchorEnabled)
            }
        }
        set(v) {
            standard.set(v, forKey: SettingsKeys.ArImageAnchorEnabled)
        }
    }
    
    static var arStickerDistanceEnabled: Bool? {
        get {
            if standard.string(forKey: SettingsKeys.ArStickerDistanceEnabled) == nil {
                return nil
            } else {
                return UserDefaults.standard.bool(forKey: SettingsKeys.ArStickerDistanceEnabled)
            }
        }
        set(v) {
            standard.set(v, forKey: SettingsKeys.ArStickerDistanceEnabled)
        }
    }
    
    static var arHitTestTypeValue: Int? {
        get {
            if standard.string(forKey: SettingsKeys.ArHitTestTypeValue) == nil {
                return nil
            } else {
                return UserDefaults.standard.integer(forKey: SettingsKeys.ArHitTestTypeValue)
            }
        }
        set(v) {
            standard.set(v, forKey: SettingsKeys.ArHitTestTypeValue)
        }
    }
    
    static var arPinMaxDistanceValue: Float? {
        get {
            if standard.string(forKey: SettingsKeys.ArPinMaxDistanceValue) == nil {
                return nil
            } else {
                return standard.float(forKey: SettingsKeys.ArPinMaxDistanceValue)
            }
        }
        set(v) {
            standard.set(v, forKey: SettingsKeys.ArPinMaxDistanceValue)
        }
    }
    
    static var arHeadingAlignEnabled: Bool? {
        get {
            if standard.string(forKey: SettingsKeys.ArHeadingAlignEnabled) == nil {
                return nil
            } else {
                return UserDefaults.standard.bool(forKey: SettingsKeys.ArHeadingAlignEnabled)
            }
        }
        set(v) {
            standard.set(v, forKey: SettingsKeys.ArHeadingAlignEnabled)
        }
    }
}
