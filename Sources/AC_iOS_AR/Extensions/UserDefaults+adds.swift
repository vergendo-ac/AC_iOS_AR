//
//  UserDefaults+adds.swift
//  myPlace
//
//  Created by Mac on 05/12/2018.
//  Copyright © 2018 Unit. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    private enum Keys {
        static let CurrentServer = "myplace_current_server"
        static let Current3DSticker = "myplace_current_3d_sticker"
        static let UseGNSSdata = "myplace_use_gnss_data"
        static let Heic2Jpeg = "myplace_heic2jpeg"
        static let EnhancedMode = "myplace_enhanced_mode"
        static let CurrentGDID = "myplace_current_gd_id"
        static let CurrentGDName = "myplace_current_gd_name"
        static let ShowStickerFrameMode = "myplace_show_sticker_frame_mode"
        static let PhotoAlbumRecoveryID = "myplace_photo_album_recovery_id"
        static let ArCameraEnabled = "myplace_arcamera_enabled"
        static let ArCameraTimerValue = "myplace_arcamera_timer_value"
        static let ArObjectsEnabled = "myplace_arobjects_enabled"
        static let AutoSaveMode = "myplace_autosave_mode"
        static let ArCameraAutoScale = "myplace_arcamera_autoscale"
        static let ArCameraAnchorType = "myplace_arcamera_anchor_type"
        static let ArKfsSelectorEnabled = "myplace_arkfs_selector_enabled"
        static let CheckNearPlaceholders = "myplace_check_near_placeholders"
        static let UseTestData = "myplace_use_test_data"
        static let VersionBuildNumber = "myplace_version_build_number"
        static let ArTraces = "myplace_ar_traces"
        static let ArCreatures = "myplace_ar_creatures"
        static let ArFun = "myplace_ar_fun"
        static let UserIdentifier = "myplace_user_identifier"
    }
    
    static var currentServer: String? {
        get {
            return standard.string(forKey: Keys.CurrentServer)
        }
        set(v) {
            standard.set(v, forKey: Keys.CurrentServer)
        }
    }

    static var current3DSticker: String? {
        get {
            return standard.string(forKey: Keys.Current3DSticker)
        }
        set(v) {
            standard.set(v, forKey: Keys.Current3DSticker)
        }
    }

    static var useGNSSdata: Bool? {
        get {
            if standard.string(forKey: Keys.UseGNSSdata) == nil {
                return nil
            } else {
                return standard.bool(forKey: Keys.UseGNSSdata)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.UseGNSSdata)
        }
    }
    
    static var heic2Jpeg: Bool? {
        get {
            if standard.string(forKey: Keys.Heic2Jpeg) == nil {
                return nil
            } else {
                return standard.bool(forKey: Keys.Heic2Jpeg)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.Heic2Jpeg)
        }
    }
    
    static var enhancedMode: Bool? {
        get {
            if standard.string(forKey: Keys.EnhancedMode) == nil {
                return nil
            } else {
                return standard.bool(forKey: Keys.EnhancedMode)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.EnhancedMode)
        }
    }
    
    static var currentGDID: String? {
        get {
            return standard.string(forKey: Keys.CurrentGDID)
        }
        set(v) {
            standard.set(v, forKey: Keys.CurrentGDID)
        }
    }
    
    static var currentGDName: String? {
        get {
            return standard.string(forKey: Keys.CurrentGDName)
        }
        set(v) {
            standard.set(v, forKey: Keys.CurrentGDName)
        }
    }
    
    static var showStickerFrameMode: Bool? {
        get {
            if standard.string(forKey: Keys.ShowStickerFrameMode) == nil {
                return nil
            } else {
                return standard.bool(forKey: Keys.ShowStickerFrameMode)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.ShowStickerFrameMode)
        }
    }
    
    static var photoAlbumRecoveryID: String? {
        get {
            return standard.string(forKey: Keys.PhotoAlbumRecoveryID)
        }
        set(v) {
            standard.set(v, forKey: Keys.PhotoAlbumRecoveryID)
        }
    }
    
    static var arCameraEnabled: Bool? {
        get {
            if standard.string(forKey: Keys.ArCameraEnabled) == nil {
                return nil
            } else {
                return standard.bool(forKey: Keys.ArCameraEnabled)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.ArCameraEnabled)
        }
    }
    
    static var arCameraTimerValue: Int? {
        get {
            if standard.string(forKey: Keys.ArCameraTimerValue) == nil {
                return nil
            } else {
                return standard.integer(forKey: Keys.ArCameraTimerValue)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.ArCameraTimerValue)
        }
    }
    
    static var arObjectsEnabled: Bool? {
        get {
            if standard.string(forKey: Keys.ArObjectsEnabled) == nil {
                return nil
            } else {
                return standard.bool(forKey: Keys.ArObjectsEnabled)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.ArObjectsEnabled)
        }
    }
    
    static var autoSaveMode: Bool? {
        get {
            if standard.string(forKey: Keys.AutoSaveMode) == nil {
                return nil
            } else {
                return standard.bool(forKey: Keys.AutoSaveMode)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.AutoSaveMode)
        }
    }
    
    static var arCameraAutoScale: Bool? {
        get {
            if standard.string(forKey: Keys.ArCameraAutoScale) == nil {
                return nil
            } else {
                return standard.bool(forKey: Keys.ArCameraAutoScale)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.ArCameraAutoScale)
        }
    }
    
    static var arCameraAnchorType: Int? {
        get {
            if standard.string(forKey: Keys.ArCameraAnchorType) == nil {
                return nil
            } else {
                return standard.integer(forKey: Keys.ArCameraAnchorType)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.ArCameraAnchorType)
        }
    }
    
    static var arKfsSelectorEnabled: Bool? {
        get {
            if standard.string(forKey: Keys.ArKfsSelectorEnabled) == nil {
                return nil
            } else {
                return UserDefaults.standard.bool(forKey: Keys.ArKfsSelectorEnabled)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.ArKfsSelectorEnabled)
        }
    }
    
    static var checkNearPlaceHolders: Bool? {
        get {
            if standard.string(forKey: Keys.CheckNearPlaceholders) == nil {
                return nil
            } else {
                return UserDefaults.standard.bool(forKey: Keys.CheckNearPlaceholders)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.CheckNearPlaceholders)
        }
    }
    
    static var useTestData: Bool? {
        get {
            if standard.string(forKey: Keys.UseTestData) == nil {
                return nil
            } else {
                return UserDefaults.standard.bool(forKey: Keys.UseTestData)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.UseTestData)
        }
    }

    /**
        recommended format: "v-b"
        example: "1.0.1-3", where
        "1.0.1" - verison number,
        "3" - build number,
        "-" - just a separator, could be any non-special character
    */
    static var versionBuildNumber: String? {
        get {
            return standard.string(forKey: Keys.VersionBuildNumber)
        }
        set(v) {
            standard.set(v, forKey: Keys.VersionBuildNumber)
        }
    }
    
    static var arTraces: Bool? {
        get {
            if standard.string(forKey: Keys.ArTraces) == nil {
                return nil
            } else {
                return standard.bool(forKey: Keys.ArTraces)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.ArTraces)
        }
    }
    
    static var arCreatures: Bool? {
        get {
            if standard.string(forKey: Keys.ArCreatures) == nil {
                return nil
            } else {
                return standard.bool(forKey: Keys.ArCreatures)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.ArCreatures)
        }
    }
    
    static var arFun: Bool? {
        get {
            if standard.string(forKey: Keys.ArFun) == nil {
                return nil
            } else {
                return standard.bool(forKey: Keys.ArFun)
            }
        }
        set(v) {
            standard.set(v, forKey: Keys.ArFun)
        }
    }
    
    static var userIdentifier: String? {
        get {
            return standard.string(forKey: Keys.UserIdentifier)
        }
        set(v) {
            standard.set(v, forKey: Keys.UserIdentifier)
        }
    }
    
}
