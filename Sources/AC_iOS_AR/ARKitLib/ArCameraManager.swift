//
//  ArCameraManager.swift
//  Developer
//
//  Created by Andrei Okoneshnikov on 19/06/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import ARKit
import CoreLocation
import CoreImage
import MobileCoreServices
import SwiftyJSON
import CoreMotion

private extension ARConfiguration {
    static func makeBaseConfiguration() -> ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.isAutoFocusEnabled = true
        configuration.worldAlignment = .gravityAndHeading
        configuration.maximumNumberOfTrackedImages = 1
        configuration.detectionImages = []
        configuration.planeDetection = [ .horizontal, .vertical ]
        print("[configuration] supportedVideoFormats:\(ARWorldTrackingConfiguration.supportedVideoFormats)")
        
        for videoFormat in ARWorldTrackingConfiguration.supportedVideoFormats {
            if videoFormat.imageResolution == CGSize(width: 1920, height: 1080) {
                configuration.videoFormat = videoFormat
                break
            }
        }
        
        return configuration
    }
}

protocol ArCameraManagerDelegate: class {
    func arCameraManager(didAdd node: SCNNode, for anchor: ARAnchor)
    func arCameraManager(didUpdate node: SCNNode, for anchor: ARAnchor)
    func arCameraManager(didFrameUpdate frame: ARFrame, for session: ARSession)
    func arCameraManager(didUpdateSessionState state: ARCamera.TrackingState)
    func arCameraManager(didUpdateLocation updateLocation: CLLocation)
    func arCameraManager(didUpdateMotion deviceMotion: CMDeviceMotion)
    func arCameraManager(didActivityUpdate activity: CMMotionActivity)
}

class ArCameraManager: NSObject, BaseCameraManagerProtocol {
    
    static let sharedInstance = ArCameraManager()
    
    private(set) var arKitSceneView: ARSCNView?
    private(set) var view: UIView!
    private(set) var isDebugInfo = false
    private(set) var worldAlignment: ARConfiguration.WorldAlignment = .gravityAndHeading
    
    var exifManager: YaExifManager?
    var locationManager: YaLocationManager?
    var motionManager: YaMotionManager?
    
    fileprivate var deviceOrientation: UIDeviceOrientation = .portrait
    weak var delegate: ArCameraManagerDelegate?
    private var debugPlanelNode: SCNNode?
    let activityManager = CMMotionActivityManager()
    
    override init() {
        super.init()
        motionManager = YaMotionManager.sharedInstance
        exifManager = YaExifManager.sharedInstance
        locationManager = YaLocationManager.sharedInstance
        locationManager?.delegate = self
        motionManager?.delegate = self
        motionManager?.setDeviceMotionUpdates(0.01)
        startTrackingActivityType()
    }
    
    deinit {
        print("Deinit ArCameraManager")
        motionManager = nil
        exifManager = nil
        locationManager = nil
        activityManager.stopActivityUpdates()
    }
    
    func setWorldAlignment(_ worldAlignment: ARConfiguration.WorldAlignment) {
        self.worldAlignment = worldAlignment
    }
    
    private func clear(clearAnchors: Bool = true) {
        if let childs = arKitSceneView?.scene.rootNode.childNodes {
            for child in childs {
                if child is ARFNode {
                    child.removeFromParentNode()
                }
            }
        }
        
        if let childs = debugPlanelNode?.parent?.childNodes {
            for child in childs {
                if child is ARFNode {
                    let worldPos = child.worldPosition
                    child.removeFromParentNode()
                    child.worldPosition = worldPos
                }
            }
        }
        
        // remove anchors
        if clearAnchors {
            for anchor in arKitSceneView?.session.currentFrame?.anchors ?? [] {
                if !(anchor is ArCameraPoseAnchor) {
                    arKitSceneView?.session.remove(anchor: anchor)
                }
            }
        }
        
        self.clearDebugInfo()
    }
    
    func enableDebugInfo(_ enabled: Bool) {
        isDebugInfo = enabled
    }
    
    func clearArkitScene(clearAnchors: Bool = true) {
        clear(clearAnchors: clearAnchors)
    }
    
    private func startTrackingActivityType() {
        activityManager.startActivityUpdates(to: OperationQueue.main) { [weak self] (activity: CMMotionActivity?) in

            guard let activity = activity else { return }
            self?.delegate?.arCameraManager(didActivityUpdate: activity)
            
        }
    }
    
    func addPreviewLayer(to view: UIView) {
        
        if self.view == view && arKitSceneView != nil {
            arKitSceneView?.session.delegate = self
            return
        }
        
        self.view = view
        self.view.isUserInteractionEnabled = true
        
        
        // Create a new scene
        arKitSceneView = ARSCNView(frame: self.view.bounds)
        arKitSceneView?.isUserInteractionEnabled = true
        print("[arcamera] view bounds:\(self.view.bounds)")
        let scene = SCNScene(named: "art.scnassets/main.scn")!
        
        // Set the scene to the view
        arKitSceneView?.scene = scene
        arKitSceneView?.autoenablesDefaultLighting = true
        arKitSceneView?.session.delegate = self
        //arKitSceneView?.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        
        //self.arKitSceneView
        //Tags.value.ARView.rawValue
        
        DispatchQueue.main.async {
            if self.arKitSceneView != nil {
                self.view.addSubview(self.arKitSceneView!)
            }
        }
    }
    
    func addFraming(to view: UIView, output: AVCaptureOutput) {
        fatalError("Cannot add framing for AV.")
    }
    
    func takePhoto(completion: @escaping (Data?, NSError?, UIDeviceOrientation?) -> ()) {
        if let img = self.snapshot() {
            let imageData = img.jpegData(compressionQuality: 1.0)!
            let image = UIImage(data: imageData)!
            let newImageData = self.imageDataWithEXIF(forImage: image, imageData) as Data
            let newImageDataGPS = addMetaData(maybeData: newImageData)
            completion(newImageDataGPS, nil, deviceOrientation)
        } else {
            let error = NSError(domain: "com.unit.error", code: 2, userInfo: [NSLocalizedDescriptionKey: "AR-camera isn't ready yet."])
            completion(nil, error, nil)
        }
    }
    
    func prepareImage(pixelBuffer: CVPixelBuffer) -> (data: Data?, orientation: UIDeviceOrientation?) {
        let image = UIImage(pixelBuffer: pixelBuffer)
        let img = self.fixOrientation(withImage: image!)
        let imageData = img.jpegData(compressionQuality: 1.0)!
        /*
        let fixedImage = UIImage(data: imageData)!
        let newImageData = self.imageDataWithEXIF(forImage: fixedImage, imageData) as Data
        let newImageDataGPS = addMetaData(maybeData: newImageData)
        */
        let newImageDataGPS = addMetaData(maybeData: imageData)
        return (newImageDataGPS, deviceOrientation)
    }
    
    func stopCaptureSession() {
        arKitSceneView?.delegate = nil
    }
    
    func removeFromPrviewLayer() {
        arKitSceneView?.session.pause()
        arKitSceneView?.delegate = nil
        arKitSceneView?.removeFromSuperview()
        arKitSceneView = nil
    }
    
    func resumeCaptureSession(completion: @escaping (CGSize) -> Void) {
        clear()
        let configuration = createARConfiguration()
        arKitSceneView?.session.run(configuration, options: [])
        arKitSceneView?.delegate = self
        completion(configuration.videoFormat.imageResolution)
    }
    
    func runArkitSession(options: ARSession.RunOptions = []) {
        let configuration = createARConfiguration()
        arKitSceneView?.session.run(configuration, options: options)
        arKitSceneView?.delegate = self
    }
    
    func shouldUseLocationServices(isUseGPS: Bool) {
        
    }
    
    func refreshSettings() {
        
    }
    
    func addMetaData(maybeData: Data?, maybeExifDeviceOrientation: Int? = nil) -> Data? {
        return exifManager?.appendDeviceMetadata(
            with: maybeData,
            maybeLocation: locationManager?.latestLocation,
            maybeHeading: locationManager?.latestHeading,
            maybeImgDesc: motionManager?.getGravityStringData(),
            maybeExifDeviceOrientation: UIDevice.current.exifOrientation()
        )
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

extension ArCameraManager {
    
    private func createARConfiguration() -> ARConfiguration {
        let config = ARConfiguration.makeBaseConfiguration()
        config.worldAlignment = self.worldAlignment
        return config
    }
    
    func setRefererenceImages(_ detectionImages: Set<ARReferenceImage>, options: ARSession.RunOptions = []) {
        clearDebugInfo()
        let config = createARConfiguration()
        (config as? ARWorldTrackingConfiguration)?.detectionImages = detectionImages
        arKitSceneView?.session.run(config, options: options)
    }
    
    fileprivate func snapshot() -> UIImage? {
        guard let arkitView = arKitSceneView, let arFrame = arkitView.session.currentFrame else {
            return nil
        }
        
        let image = UIImage(pixelBuffer: arFrame.capturedImage)
        let fixImage = self.fixOrientation(withImage: image!)
        return fixImage
    }
    
    fileprivate func imageDataWithEXIF(forImage image: UIImage, _ imageData: Data) -> CFMutableData {
        // get EXIF info
        let cgImage = image.cgImage
        let newImageData:CFMutableData = CFDataCreateMutable(nil, 0)
        let type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, "image/jpg" as CFString, kUTTypeImage)
        let destination:CGImageDestination = CGImageDestinationCreateWithData(newImageData, (type?.takeRetainedValue())!, 1, nil)!
        
        let imageSourceRef = CGImageSourceCreateWithData(imageData as CFData, nil)
        let currentProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef!, 0, nil)
        let mutableDict = NSMutableDictionary(dictionary: currentProperties!)
        
        //if let location = engine?.userLocationEstimate()?.location {
        /*if let location = locationManager?.latestLocation {
            mutableDict.setValue(gpsMetadata(withLocation: location), forKey: kCGImagePropertyGPSDictionary as String)
        }*/
        
        CGImageDestinationAddImage(destination, cgImage!, mutableDict as CFDictionary)
        CGImageDestinationFinalize(destination)
        
        return newImageData
    }
    
    fileprivate func gpsMetadata(withLocation location: CLLocation) -> NSMutableDictionary {
        let f = DateFormatter()
        f.timeZone = TimeZone(abbreviation: "UTC")
        
        f.dateFormat = "yyyy:MM:dd"
        let isoDate = f.string(from: location.timestamp)
        
        f.dateFormat = "HH:mm:ss.SSSSSS"
        let isoTime = f.string(from: location.timestamp)
        
        let GPSMetadata = NSMutableDictionary()
        let altitudeRef = Int(location.altitude < 0.0 ? 1 : 0)
        let latitudeRef = location.coordinate.latitude < 0.0 ? "S" : "N"
        let longitudeRef = location.coordinate.longitude < 0.0 ? "W" : "E"
        
        // GPS metadata
        GPSMetadata[(kCGImagePropertyGPSLatitude as String)] = abs(location.coordinate.latitude)
        GPSMetadata[(kCGImagePropertyGPSLongitude as String)] = abs(location.coordinate.longitude)
        GPSMetadata[(kCGImagePropertyGPSLatitudeRef as String)] = latitudeRef
        GPSMetadata[(kCGImagePropertyGPSLongitudeRef as String)] = longitudeRef
        GPSMetadata[(kCGImagePropertyGPSAltitude as String)] = Int(abs(location.altitude))
        GPSMetadata[(kCGImagePropertyGPSAltitudeRef as String)] = altitudeRef
        GPSMetadata[(kCGImagePropertyGPSTimeStamp as String)] = isoTime
        GPSMetadata[(kCGImagePropertyGPSDateStamp as String)] = isoDate
        
        return GPSMetadata
    }
    
    fileprivate func _imageOrientation(forDeviceOrientation deviceOrientation: UIDeviceOrientation, isMirrored: Bool) -> UIImage.Orientation {
        
        switch deviceOrientation {
        case .landscapeLeft:
            return isMirrored ? .upMirrored : .up
        case .landscapeRight:
            return isMirrored ? .downMirrored : .down
        default:
            break
        }
        
        return isMirrored ? .leftMirrored : .right
    }
    
    func fixOrientation(withImage image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        var isMirrored = false
        let orientation = image.imageOrientation
        if orientation == .rightMirrored
            || orientation == .leftMirrored
            || orientation == .upMirrored
            || orientation == .downMirrored {
            
            isMirrored = true
        }
        
        let newOrientation = _imageOrientation(forDeviceOrientation: deviceOrientation, isMirrored: isMirrored)
        
        if image.imageOrientation != newOrientation {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: newOrientation)
        }
        
        return image
    }
    
    func addPoseExifMetadata(forImage image: UIImage, _ imageData: Data, posesInfo: PoseMetadata) -> CFMutableData {
        // get EXIF info
        let cgImage = image.cgImage
        let newImageData:CFMutableData = CFDataCreateMutable(nil, 0)
        let type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, "image/jpg" as CFString, kUTTypeImage)
        let destination:CGImageDestination = CGImageDestinationCreateWithData(newImageData, (type?.takeRetainedValue())!, 1, nil)!
        
        let imageSourceRef = CGImageSourceCreateWithData(imageData as CFData, nil)
        let currentProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef!, 0, nil)
        let mutableDict = NSMutableDictionary(dictionary: currentProperties!)
        
        let exifDictionary: NSMutableDictionary = (mutableDict[kCGImagePropertyExifDictionary as String] as? NSMutableDictionary)!
        exifDictionary[kCGImagePropertyExifUserComment as String] = posesInfo.asJson().rawString(options: [])
        mutableDict[kCGImagePropertyExifDictionary as String] = exifDictionary
        
        CGImageDestinationAddImage(destination, cgImage!, mutableDict as CFDictionary)
        CGImageDestinationFinalize(destination)
        
        return newImageData
    }
}

extension ArCameraManager: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            guard let _ = self.arKitSceneView else {
                return
            }
            
            if self.debugPlanelNode == nil || self.debugPlanelNode?.parent != node, let imageAnchor = anchor as? ARImageAnchor, self.isDebugInfo {
                self.clearDebugInfo()
                // Create a plane to visualize the initial position of the detected image.
                let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                                     height: imageAnchor.referenceImage.physicalSize.height)
                let panelNode = SCNNode(geometry: plane)
                panelNode.opacity = 0.4
                
                if let material = plane.firstMaterial {
                    material.diffuse.contents = UIColor.blue
                }
                
                /*
                 `SCNPlane` is vertically oriented in its local coordinate space, but
                 `ARImageAnchor` assumes the image is horizontal in its local space, so
                 rotate the plane to match.
                 */
                panelNode.eulerAngles.x = -.pi / 2
                
                /*
                 Image anchors are not tracked after initial detection, so create an
                 animation that limits the duration for which the plane visualization appears.
                 */
                node.addChildNode(panelNode)
                self.debugPlanelNode = panelNode
            }
            
            self.delegate?.arCameraManager(didAdd: node, for: anchor)
        }
    }
    
    func clearDebugInfo() {
        debugPlanelNode?.removeFromParentNode()
        debugPlanelNode = nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            guard let _ = self.arKitSceneView else {
                return
            }
            
            self.delegate?.arCameraManager(didUpdate: node, for: anchor)
        }
    }
}

extension ArCameraManager: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.delegate?.arCameraManager(didFrameUpdate: frame, for: session)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        delegate?.arCameraManager(didUpdateSessionState: camera.trackingState)
    }
}

extension ArCameraManager: YaLocationManagerDelegate {
    func update(location: CLLocation) {
        delegate?.arCameraManager(didUpdateLocation: location)
    }
}

extension ArCameraManager: YaMotionManagerDelegate {
    func motionManager(didUpdate deviceMotion: CMDeviceMotion) {
        delegate?.arCameraManager(didUpdateMotion: deviceMotion)
    }
}
