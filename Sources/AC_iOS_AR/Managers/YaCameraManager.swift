//
//  YaCameraManager.swift
//  myPlace
//
//  Created by Mac on 02/05/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol BaseCameraManagerProtocol: class {
    var exifManager: YaExifManager? { get set }
    var locationManager: YaLocationManager? { get set }
    var motionManager: YaMotionManager? { get }
    
    func addPreviewLayer(to view: UIView)
    
    func addFraming(to view: UIView, output: AVCaptureOutput)
    
    func shouldUseLocationServices(isUseGPS: Bool)
    func refreshSettings()
    
    func takePhoto(completion: @escaping (Data?, NSError?, UIDeviceOrientation?) -> Swift.Void)
    func stopCaptureSession()
    func resumeCaptureSession(completion: @escaping (CGSize) -> Void)
    func addMetaData(maybeData: Data?, maybeExifDeviceOrientation: Int?) -> Data?
    
    func flashLight(turn to: Bool)
}

class YaCameraManager: BaseCameraManagerProtocol {
    
    static let sharedInstance = YaCameraManager()
    
    var cameraManager: CameraManager?
    var motionManager: YaMotionManager?
    var exifManager: YaExifManager?
    var locationManager: YaLocationManager?
    
    init() {
        motionManager = YaMotionManager.sharedInstance
        exifManager = YaExifManager.sharedInstance
        locationManager = YaLocationManager.sharedInstance
        self.activateCameraManager()
    }
    
    deinit {
        print("Deinit YaCameraManager")
        cameraManager = nil
        motionManager = nil
        exifManager = nil
        locationManager = nil
    }

    private func activateCameraManager() {
        
        self.cameraManager = CameraManager.sharedInstance
        
        if let cm = self.cameraManager {
            cm.shouldEnablePinchToZoom = true
            cm.showAccessPermissionPopupAutomatically = true
            cm.writeFilesToPhoneLibrary = false
            cm.shouldEnableTapToFocus = true
            cm.shouldUseLocationServices = UserDefaults.useGNSSdata ?? true
            cm.cameraOutputQuality = .hd
            cm.cameraOutputMode = .stillImage
            //cm.addPreviewLayerToView(self.photoImageView!)
            
            cm.shouldRespondToOrientationChanges = true //do not rotate image due to angle of phone
            cm.animateShutter = false
            cm.shouldEnableExposure = false
            if cm.hasFlash {
                cm.flashMode = .off
            }
            
            //199:
            /*
             /**
             Property to determine if manager should let to rotate VideoBuffer when the orientation changes.
             - note: Default value is **true**
             */
             open var shouldLetVideoBufferRotation = true
             */
            //1273:
            /*
             if !shouldKeepViewAtOrientationChanges {
             if let validPreviewLayerConnection = validPreviewLayer.connection,
             validPreviewLayerConnection.isVideoOrientationSupported,
             shouldLetVideoBufferRotation {
             validPreviewLayerConnection.videoOrientation = _currentPreviewVideoOrientation()
             }
             }
             
             */
            cm.shouldLetVideoBufferRotation = false
        }
        
    }

    func addPreviewLayer(to view: UIView) {
        if let cm = self.cameraManager {
            print("sublayers.count = \(view.layer.sublayers?.count ?? 0)")
            cm.addPreviewLayerToView(view)
        }
    }
    
    func addFraming(to view: UIView, output: AVCaptureOutput) {
        if let cm = self.cameraManager {
            cm.frameOutput = output
            cm.addPreviewLayerToView(view, newCameraOutputMode: .videoOnly)
        }
    }
    
    func shouldUseLocationServices(isUseGPS: Bool) {
        if let cm = self.cameraManager {
            cm.shouldUseLocationServices = isUseGPS
        }
    }
    
    func takePhoto(completion: @escaping (Data?, NSError?, UIDeviceOrientation?) -> Swift.Void) {
        var nserror: NSError?
        
        if let cameraIsReady = cameraManager?.cameraIsReady, cameraIsReady {
            cameraManager?.capturePictureDataWithCompletion({ [weak self] (captureResult) in
                
                guard let self = self else { return }
                
                let deviceOrientation = self.motionManager?.deviceOrientation()
                let locationError = self.locationManager?.latestError
                
                nserror = (locationError == nil) ? nil : NSError(domain: "com.unit.ar.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Location error \(locationError!.localizedDescription)."])
                
                switch captureResult {
                case let .success(content):
                    completion(self.addMetaData(maybeData: content.asData, maybeExifDeviceOrientation: UIDevice.current.exifOrientation()), nserror, deviceOrientation)
                case let .failure(error):
                    nserror = NSError(domain: "com.unit.ar.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Take photo error \(error.localizedDescription)."])
                    completion(nil, nserror, deviceOrientation)
                }
                
            })
        } else {
            nserror = NSError(domain: "com.unit.ar.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Photo camera isn't ready yet."])
            completion(nil, nserror, nil)
        }
        
    }
    
    func addMetaData(maybeData: Data?, maybeExifDeviceOrientation: Int? = nil) -> Data? {
        return exifManager?.appendDeviceMetadata(
            with: maybeData,
            maybeLocation: locationManager?.latestLocation,
            maybeHeading: locationManager?.latestHeading,
            maybeImgDesc: motionManager?.getGravityStringData(),
            maybeExifDeviceOrientation: maybeExifDeviceOrientation
        )
    }
    
    func stopCaptureSession() {
        self.cameraManager?.stopCaptureSession()
        self.motionManager?.stopUpdate()
        self.locationManager?.stopUpdating()
    }
    
    func resumeCaptureSession(completion: @escaping (CGSize) -> Void) {
        self.motionManager?.startUpdate()
        self.locationManager?.startUpdating()
        if let isSessionRunning = self.cameraManager?.captureSession?.isRunning, let cameraIsReady = self.cameraManager?.cameraIsReady,
            !isSessionRunning && cameraIsReady {
            self.cameraManager?.resumeCaptureSession()
            if let cameraOutputQuality = self.cameraManager?.cameraOutputQuality {
                switch cameraOutputQuality {
                case .hd:
                    completion(CGSize(width: 1920, height: 1080))
                default:
                    completion(.zero)
                }
            } else {
                completion(CGSize(width: 777, height: 777))
            }
        }
    }
    
    func refreshSettings() {
      if let quality = self.cameraManager?.cameraOutputQuality, quality != .hd {
        self.cameraManager?.cameraOutputQuality = .hd
      }
      self.shouldUseLocationServices(isUseGPS: UserDefaults.useGNSSdata ?? true)
    }
    
    func flashLight(turn to: Bool) {
        self.toggleTorch(on: to)
    }
    
    private func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
}
