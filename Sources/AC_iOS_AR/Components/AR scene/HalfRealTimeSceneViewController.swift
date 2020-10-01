//
//  HalfRealTimeSceneViewController.swift
//  YaPlace
//
//  Created by Rustam Shigapov on 11/09/2019.
//  Copyright (c) 2019 SKZ. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import AVFoundation
import ARKit
import CoreLocation
import CoreMotion
import Combine

protocol HalfRealTimeSceneDisplayLogic: class {
    
    func displayStickers3D(viewModel: HalfRealTimeScene.GetStickers3D.ViewModel)
    func displayNodes(viewModel: HalfRealTimeScene.Nodes.ViewModel)
    func displayClusters(viewModel: HalfRealTimeScene.Clusters.ViewModel)
    func displayStart(viewModel: HalfRealTimeScene.Start.ViewModel)
    func displayMarkers2DMovable(viewModel: HalfRealTimeScene.Markers2DMovable.ViewModel)
    func displayKfsFrameSelector(viewModel: HalfRealTimeScene.FrameSelector.ViewModel)

    func displayArSessionRun(viewModel: HalfRealTimeScene.ArSessionRun.ViewModel)
    func restoreCameraState()
    
    func displayTakeNextPhoto(viewModel: HalfRealTimeScene.TakeNextPhoto.ViewModel)
    
    func displayLocalizeData(viewModel: HalfRealTimeScene.LocalizeData.ViewModel)
    func displayLocalize(viewModel:  HalfRealTimeScene.Localize.ViewModel)
    func displayARObjects(viewModel:  HalfRealTimeScene.ARObjects.ViewModel)
    
}

class HalfRealTimeSceneViewController: UIViewController {
    
    static let shared = HalfRealTimeSceneViewController()
    
    //MARK: Properties
    var interactor: HalfRealTimeSceneBusinessLogic?
    
    var router: (NSObjectProtocol & HalfRealTimeSceneRoutingLogic & HalfRealTimeSceneDataPassing)?
    
    var cameraManager: BaseCameraManagerProtocol?

    private var cameraState: HalfRealCameraState = .normal(prev: nil) {
        didSet {
            let proc = {
                if let camera = (self.cameraManager as? ArCameraManager)?.arKitSceneView?.session.currentFrame?.camera {
                    self.arCameraManager(didUpdateSessionState: camera.trackingState)
                }
                
                switch self.cameraState {
                case .arkit:
                    print("arkit")
                default:
                    
                    print("default")
                }
            }
            Thread.isMainThread ? proc() : DispatchQueue.main.async(execute: proc)
        }
    }
    
    // MARK: Arkit properties
    private let syncRoot: NSRecursiveLock = NSRecursiveLock()

    private let anchorMode: ArCameraContext.AnchorMode = .off
    private let isArkitAutoScaleMode = false
    private var frameCounter = 0
    private var kfsSelectorEnabled = true
    private var arSessionStatusEnabled = false
    private static let requestDeadline = 1.0
    private var lastConfigOptions: ARSession.RunOptions?
    private var animationTimer: Timer?
    private var showArPlane = true
    private var arObjectsEnabled = true
    private var arAnimationDuration: TimeInterval = 1.5
    private let meshNodeName = "MeshNode"
    private var selectNumber:Int = 0
    private var dataIsTaken: Bool = true
    
    private let noStickersMaxSeconds: Int = 3 //10
    
    private var arBackView: UIView?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        HalfRealTimeSceneConfigurator.sharedInstance.configure(self)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeSettings()
    }
    
    private func makeSettings() {
        let request = HalfRealTimeScene.Settings.Request(pinViewSize: self.view.frame.size)
        self.interactor?.makeSettings(request: request)
    }
    
    //MARK: SDK AR start block
    
    func start() {
        let startRequest = HalfRealTimeScene.Start.Request(isStartFetching: self.arBackView != nil)
        interactor?.start(request: startRequest)
    }
    
    func set(arView backView: UIView) {
        self.arBackView = backView
    }
    
    private func startAR() {
        UIApplication.shared.isIdleTimerDisabled = true
        self.clearNodes {
            self.switchCamera(isON: true)
        }
    }
    
    func stopAR() {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
            self.switchCamera(isON: false)
        }
    }
    
    func getLocalizationData(completion: @escaping (_ imageData: Data?, _ location: CLLocation?, _ photoInfo: [String:Any]?, _ pose: Pose?) -> Void) {
        let request = HalfRealTimeScene.LocalizeData.Request(completion: completion)
        interactor?.getLocalizeData(request: request)
    }
    
    func show(localizationResult: LocalizationResult) {
        let request = HalfRealTimeScene.ARObjects.Request(localizationResult: localizationResult)
        interactor?.showARObjects(request: request)
    }

    
    private func restoreArCameraManager() {
        guard UserDefaults.arCameraEnabled ?? true, let cameraManager = (self.cameraManager as? ArCameraManager) else {
            return
        }
        
        arSessionStatusEnabled = (UserDefaults.arStatusEnabled ?? false)
        let context = ArCameraContext()
        context.setArPlaneMaxDistance(Double(UserDefaults.arPlaneMaxDistanceValue ?? 200))
        
        if context.arPlaneMaxDistance > 0 {
            context.setScaleCalculationType(.arkit)
            showArPlane = arSessionStatusEnabled
            if arSessionStatusEnabled, let arkitView = cameraManager.arKitSceneView {
                arkitView.debugOptions = [SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showWorldOrigin]
            }
            
            let hitTestType: ARHitTestResult.ResultType
            switch UserDefaults.arHitTestTypeValue ?? 1 {
            case 0:
                hitTestType = .existingPlane
            case 1:
                hitTestType = .existingPlaneUsingExtent
            case 2:
                hitTestType = .existingPlaneUsingGeometry
            case 3:
                hitTestType = .featurePoint
            default:
                hitTestType = .existingPlaneUsingExtent
            }
            context.setArHitTestResult(hitTestType)
        } else {
            showArPlane = false
            context.setScaleCalculationType(.poses)
        }
        
        cameraManager.delegate = self
        
        if UserDefaults.arHeadingAlignEnabled ?? true {
            cameraManager.setWorldAlignment(.gravityAndHeading)
        } else {
            cameraManager.setWorldAlignment(.gravity)
        }
        
        kfsSelectorEnabled = UserDefaults.arKfsSelectorEnabled ?? false
        arObjectsEnabled = UserDefaults.arObjectsEnabled ?? false
        arAnimationDuration = UserDefaults.arAnimationDurationValue != nil ? TimeInterval(UserDefaults.arAnimationDurationValue!) : arAnimationDuration
        context.setAnimationDuration(arAnimationDuration)
        cameraManager.enableDebugInfo(false)
        let arCameraAnchorType = UserDefaults.arCameraAnchorType ?? 1
        
        switch arCameraAnchorType {
        case 1:
            context.setAnchorMode(.points)
        case 2:
            if arSessionStatusEnabled {
                cameraManager.enableDebugInfo(true)
            }
            context.setAnchorMode(.image)
        case 3:
            context.setAnchorMode(.sticker)
        case 4:
            context.setAnchorMode(.allStickers)
        default:
            context.setAnchorMode(.off)
        }
        
        cameraManager.resumeCaptureSession { _ in
            self.cameraState = .arkit(context: context, prev: nil)
            self.interactor?.startArCameraManager(request: HalfRealTimeScene.StartArCamera.Request())
            self.sticker3DRequest(force: true)
            self.updateArTrace(arkitView: cameraManager.arKitSceneView, cameraPose: nil, cameraAngles: nil)
            self.setupArCreature(arkitView: cameraManager.arKitSceneView, superView: self.view)
        }
        
    }
    
    private func restoreCameraManager() {
        
        guard let viewForAR = self.arBackView else { return }
        
        //TODO: make self.view frame equals to arBackView.bounds! Perhaps no...
        
        let isArCameraEnabled = UserDefaults.arCameraEnabled ?? true
        cameraManager = isArCameraEnabled ? ArCameraManager.sharedInstance : YaCameraManager.sharedInstance
        
        if isArCameraEnabled {
            if let cm = (cameraManager as? ArCameraManager), cm.view == nil {
                cm.addPreviewLayer(to: viewForAR)
            }
            restoreArCameraManager()
            return
        }
        
        cameraManager?.addPreviewLayer(to: viewForAR)
        cameraManager?.refreshSettings()
        
        cameraManager?.resumeCaptureSession { size in
            print("CGSize = \(size)")
        }
        
        cameraState = .normal(prev: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.askSelfToTakePhoto()
        })
        
    }
    
    func switchCamera(isON: Bool) {
        switch isON {
        case true:
            if let cameraManager = cameraManager as? ArCameraManager, let _ = cameraManager.arKitSceneView {
                //cameraManager.removeFromPrviewLayer()
            }
            self.restoreCameraManager()
        default:
            if let cameraManager = cameraManager as? ArCameraManager {
                cameraManager.arKitSceneView?.session.pause()
                let request = HalfRealTimeScene.ClearArContent.Request(cameraManager: cameraManager, clearAnchors: true)
                interactor?.removeArContent(request: request)
            }
            self.cameraManager?.stopCaptureSession()
        }
    }
    
    fileprivate func askSelfToTakePhoto() {
        
        switch cameraState {
        case .normal:
            break
        default:
            return
        }
        
        self.takePhoto(completion: { [weak self] (maybeData, maybeAlert, maybeDeviceOrientation) in
            self?.savePhoto(maybeImageData: maybeData, maybeDeviceOrientation: maybeDeviceOrientation)
            print("askSelfToTakePhoto")
            
        })
    }
    
    fileprivate func savePhoto(maybeImageData: Data?, maybeDeviceOrientation: UIDeviceOrientation?) {
        if let imageData = maybeImageData {
            let imageLocation = cameraManager?.exifManager?.getLocation(maybeData: imageData)
            let currentLocation = (imageLocation == nil) ? cameraManager?.locationManager?.latestLocation : imageLocation!
            let request = HalfRealTimeScene.SavePhoto.Request(
                image: ImageModels.Image(data: imageData, filename: "\(ImageModels.ImageSource.PhotoCamera.rawValue)1.jpg", size: nil),
                deviceOrientation: maybeDeviceOrientation,
                currentLocation: currentLocation
            )
            interactor?.savePhoto(request: request)
        }
    }
    
    func takePhoto(completion: @escaping (Data?, NSError?, UIDeviceOrientation?) -> Void) {
        let request = HalfRealTimeScene.TakeNextPhoto.Request(completion: completion)
        self.interactor?.takeNextPhoto(request: request)
    }
    
    private func showClusters(clusters: [UIView]?) {
        clearClusters() {
            if let clusterViews = clusters, clusterViews.count > 0 {
                clusterViews.forEach { self.view.addSubview($0) }
            }
        }
    }
    private func clearClusters(completion: @escaping () -> Void) {
        
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.clearClusters(completion: completion)
            }
            return
        }
        
        for v in self.view.subviews {
            if v.tag == Tags.value.StickerMarkerClusterView.rawValue {
                v.removeFromSuperview()
            }
        }
        
        completion()
    }

    
    private func showNodes(nodes: [UIView]?, frames: [UIView]?, completion: @escaping () -> Void ) {
        self.clearNodes {
            guard let viewForAR = self.arBackView else { return }
            if let nodesViews = nodes, nodesViews.count > 0 {
                print("kkk view - \(self.view.frame.size)")
                
                for nodeView in nodesViews {
                    viewForAR.addSubview(nodeView) //nodesView
                }
            }
            
            if let frameViews = frames, frameViews.count > 0 {
                for frameView in frameViews {
                    viewForAR.addSubview(frameView)
                }
            }
            
            completion()
        }
    }
    
    private func clearNodes(completion: @escaping () -> Void) {
        guard let viewForAR = self.arBackView else { return }
        
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.clearNodes(completion: completion)
            }
            return
        }
        
        for v in viewForAR.subviews {
            if v.tag == Tags.value.HalfRealtimeStickerMarkerView.rawValue || v.tag == Tags.value.StickerMarkerFrameView.rawValue {
                v.removeFromSuperview()
            }
        }
        
        completion()
    }
    
    private func updateArTrace(arkitView: ARSCNView?, cameraPose: simd_float4x4?, cameraAngles: simd_float3?) {
        let request = HalfRealTimeScene.ArTrace.Request(arkitView: arkitView, cameraPose: cameraPose, cameraAngles: cameraAngles)
        interactor?.updateArTrace(request: request)
    }
    
    private func setupArCreature(arkitView: ARSCNView?, superView: UIView?) {
        let request = HalfRealTimeScene.ArCreature.Request(arkitView: arkitView, superView: superView)
        interactor?.setupArCreature(request: request)
    }
    
    private func cleanUpUI() {
        if let cameraManager = cameraManager as? ArCameraManager {
            cameraManager.arKitSceneView?.session.pause()
            let request = HalfRealTimeScene.ClearArContent.Request(cameraManager: cameraManager, clearAnchors: true)
            interactor?.removeArContent(request: request)
        }
    }
    
    private func kfsSelectorRequest(posePixelBuffer: PixelBufferWithPose) {
        guard self.cameraState.isArkit else {
            //print("[check] yet handling, isArkit:\(self.cameraState.isArkit)")
            return
        }
        
        DispatchQueue.main.async {
            let request = HalfRealTimeScene.FrameSelector.Request(posePixelBuffer: posePixelBuffer)
            self.interactor?.kfsFrameSelector(request: request)
        }
    }

}

extension HalfRealTimeSceneViewController: HalfRealTimeSceneDisplayLogic {
    
    func displayMarkers2DMovable(viewModel: HalfRealTimeScene.Markers2DMovable.ViewModel) {
        //something for 2D markers after moving
        
        // MARK: show info stickers
    }
    
    private func setSafeState(_ state: HalfRealCameraState) {
        syncRoot.lock()
        cameraState = state
        syncRoot.unlock()
    }
    
    func displayStickers3D(viewModel: HalfRealTimeScene.GetStickers3D.ViewModel) {
        
        guard let cameraManager = self.cameraManager as? ArCameraManager else {
            return
        }
        
        let scene = viewModel.scene
        
        switch self.cameraState {
        case .preparing(let prev, _):
            switch prev {
            case .arkit(let context, _):
                
                guard context.cameraPoses.count == context.scenes.count + 1 else {
                    self.setSafeState(.arkit(context: context, prev: nil))
                    self.sticker3DRequest()
                    return
                }
                
                self.interactor?.clearArContent(request: HalfRealTimeScene.ClearArContent.Request(cameraManager: cameraManager, clearAnchors: false))
                
                if let options = lastConfigOptions {
                    cameraManager.runArkitSession(options: options)
                    lastConfigOptions = nil
                }
                
                guard let arkitView = cameraManager.arKitSceneView else {
                    context.clear()
                    self.setSafeState(.arkit(context: context, prev: nil))
                    self.sticker3DRequest()
                    return
                }
                
                let prevMainNode = context.mainNode
                let prevScene = context.currentScene
                _ = context.put(scene: scene).put(arkitView: arkitView)
                
                // MARK: clear anchors
                
                for anchor in arkitView.session.currentFrame?.anchors ?? [] {
                    if !(anchor is ArCameraPoseAnchor) {
                        if (anchor is ArPointAnchor && prevMainNode == nil) || anchor is ArStickerAnchor || anchor is ARImageAnchor {
                            arkitView.session.remove(anchor: anchor)
                        }
                    }
                }
                
                // MARK: create AR scene
                
                let beforeAnimation = {
                    
                    // rebase to previos main node
                    
                    if let _ = context.getMainNode(), let previous = prevScene, context.anchorMode == .points {
                        let request = HalfRealTimeScene.MainNode.Request(prevScene: previous, context: context)
                        self.interactor?.rebaseToLastAnchor(request: request)
                    }
                    
                    print("[anchor] s before animation")
                    if let cameraPose = arkitView.session.currentFrame?.camera.transform, let nodesData = context.calc2DNodes(cameraPose: cameraPose) {
                        
                        let request = HalfRealTimeScene.Nodes.Request(
                            maybeNodes: nodesData,
                            maybeStickers: scene.stickersData,
                            deviceOrientation: self.cameraManager?.motionManager?.deviceOrientation()
                        )
                        
                        self.interactor?.show2DMarkers(request: request)
                    }
                    self.setSafeState(.preparing(prev: prev, startAnimation: true))
                }
                
                context.showLastScene(updateScale: context.isAutoScale ? !context.lastScale.isLocal : false, isEnabled: arObjectsEnabled, animated: arAnimationDuration > 0, beforeAnimation: beforeAnimation) { res in
                    
                    print("[anchor] show scene, after animation, result:\(res)")
                    
                    guard res else {
                        self.setSafeState(.arkit(context: context, prev: nil))
                        self.sticker3DRequest()
                        return
                    }
                    
                    // MARK: set stickers pose to kfs selector
                    
                    if self.kfsSelectorEnabled && (context.lastScale.isLocal || !context.isAutoScale), let lastPose = context.lastPose {
                        self.updateKfsStickesPose(cameraPose: lastPose)
                    }
                    
                    // MARK: anchors
                    
                    let request = HalfRealTimeScene.HandleAnchors.Request(cameraManager: cameraManager, context: context, scene: scene)
                    self.interactor?.handleAnchors(request: request)
                    
                    
                    self.setSafeState(.arkit(context: context, prev: nil))
                    self.sticker3DRequest()
                    
                    DispatchQueue.main.async {
                        let request = HalfRealTimeScene.VideoSticker.Request(context: context, arkitView: arkitView)
                        self.interactor?.handleVideoSticker(request: request)
                    }
                    
                }
            default:
                self.sticker3DRequest()
                print("[anchor] invalid prev state:\(prev)")
                return
            }
        default:
            self.sticker3DRequest()
            print("[anchor] invalid state:\(cameraState)")
            break
        }
    }
    
    func displayNodes(viewModel: HalfRealTimeScene.Nodes.ViewModel) {
        self.showNodes(nodes: viewModel.views, frames: viewModel.frames) { [weak self] in
            guard let self = self else { return }
            //self.askSelfToTakePhoto()
        }
    }
    
    func displayClusters(viewModel: HalfRealTimeScene.Clusters.ViewModel) {
        self.showClusters(clusters: viewModel.clusters)
    }
    
    func displayStart(viewModel: HalfRealTimeScene.Start.ViewModel) {
        if viewModel.isStartFetching {
            self.startAR()
        }
    }
    
    func displayArSessionRun(viewModel: HalfRealTimeScene.ArSessionRun.ViewModel) {
        
        print("[loc] * lock displayArSessionRun")
        syncRoot.lock()
        
        defer {
            syncRoot.unlock()
            print("[loc] * unlock displayArSessionRun")
        }
        
        lastConfigOptions = viewModel.options
        
    }
    
    func restoreCameraState() {
        print("[loc] * lock restoreCameraState")
        syncRoot.lock()
        
        defer {
            syncRoot.unlock()
            print("[loc] * unlock restoreCameraState")
            self.sticker3DRequest()
        }
        
        print("[localization] restoreCameraState state:\(cameraState), isMainThread:\(Thread.isMainThread)")
        
        switch self.cameraState {
        case .preparing(let prev, _):
            switch prev {
            case .arkit(let context, _):
                self.cameraState = prev
                context.clearLast()
            default:
                break
            }
        default:
            break
        }
    }
    
    private func updateKfsStickesPose(cameraPose: simd_float4x4) {
        guard let scene = cameraState.arContext?.currentScene else {
            return
        }
        
        var stickerPoses: [simd_float4x4] = []
        
        for (_, items) in scene.arfNodes {
            if items.count == 0 {
                continue
            }
            
            var center = simd_float3(0, 0, 0)
            for item in items {
                center += item.simdWorldPosition
            }
            
            center = center / Float(items.count)
            let pose = simd_float4x4(rotation: items[0].simdWorldTransform.upperLeft3x3, position: center)
            stickerPoses.append(pose)
        }
        
    }
    
    private func sticker3DRequest(deadline: Double = requestDeadline, force: Bool = false) {
        if !kfsSelectorEnabled, force {
            
            print("[loc] start task for sticker3DRequest")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + deadline) {
                guard let posePixelBuffer = self.cameraState.arContext?.posePixelBuffer else {
                    print("[loc] pixelBuffer not ready")
                    self.sticker3DRequest(deadline: deadline, force: force)
                    return
                }
                
                DispatchQueue.global().async {
                    let viewModel = HalfRealTimeScene.FrameSelector.ViewModel(posePixelBuffer: posePixelBuffer)
                    self.displayKfsFrameSelector(viewModel: viewModel)
                }
            }
        }
    }
    
    private func createCameraPosesAnchors() {
        guard let context = cameraState.arContext, let cameraManager = self.cameraManager as? ArCameraManager else {
            return
        }
        
        // remove anchors
        for anchor in cameraManager.arKitSceneView?.session.currentFrame?.anchors ?? [] {
            if anchor is ArCameraPoseAnchor {
                cameraManager.arKitSceneView?.session.remove(anchor: anchor)
            }
        }
        
        // add anchor on camera pose
        for pose in context.cameraPoses.suffix(10) {
            if  cameraManager.arKitSceneView?.session.currentFrame?.anchors.first(where: {$0.name == pose.id}) == nil {
                let anchor = ArCameraPoseAnchor(name: pose.id, transform: pose.pose)
                cameraManager.arKitSceneView?.session.add(anchor: anchor)
            }
        }
    }
    
    func displayKfsFrameSelector(viewModel: HalfRealTimeScene.FrameSelector.ViewModel) {
        print("[loc] * lock displayKfsFrameSelector")
        syncRoot.lock()
        
        defer {
            syncRoot.unlock()
            print("[loc] * unlock displayKfsFrameSelector")
        }
        
        print("[loc] displayKfsFrameSelector, isMainThread:\(Thread.isMainThread)")
        
        guard let cameraManager = self.cameraManager as? ArCameraManager else {
            self.sticker3DRequest()
            return
        }
        
        switch cameraState {
        case .arkit(let context, _):
            let prev = self.cameraState
            self.cameraState = .preparing(prev: prev)
            let posePixelBuffer = viewModel.posePixelBuffer
            /*
            let result = cameraManager.prepareImage(pixelBuffer: posePixelBuffer.image)
            
            guard let dataImage = result.data else {
                self.cameraState = prev
                self.sticker3DRequest()
                return
            }*/
            
            let image = UIImage(pixelBuffer: posePixelBuffer.image)
            let img = cameraManager.fixOrientation(withImage: image!)
            let dataImage = img.jpegData(compressionQuality: 1.0)!
            
            _ = context.put(pose: posePixelBuffer.cameraPose, id: posePixelBuffer.id)
            self.createCameraPosesAnchors()
            
            let fileName = "\(ImageModels.ImageSource.PhotoCamera.rawValue)1.jpg"
            let imageInfo = ImageModels.Image(data: dataImage, filename: fileName, size: UIImage(data: dataImage)!.size)
            
            if let arkitView = cameraManager.arKitSceneView,
               let intrinsics = arkitView.session.currentFrame?.camera.intrinsics,
               let transform = arkitView.session.currentFrame?.camera.transform {
                
                let qw = sqrt(1 + transform.columns.0.x + transform.columns.1.y + transform.columns.2.z) / 2.0
                let qx = (transform.columns.2.y - transform.columns.1.z) / (qw * 4.0)
                let qy = (transform.columns.0.z - transform.columns.2.x) / (qw * 4.0)
                let qz = (transform.columns.1.x - transform.columns.0.y) / (qw * 4.0)
                
                let orientation = Quaternion(w: qw, x: qx, y: qy, z: qz)
                let position = Vector3d(x: transform.columns.3.x, y: transform.columns.3.y, z: transform.columns.3.z)
                let pose = Pose(position: position, orientation: orientation)
                
                let request = HalfRealTimeScene.Localize.Request(image: imageInfo, intrinsics: intrinsics, cameraPose: pose)
                self.interactor?.localize(request: request)
            }
            
        default:
            break
        }
    }
    
    func displayTakeNextPhoto(viewModel: HalfRealTimeScene.TakeNextPhoto.ViewModel) {
        self.cameraManager?.takePhoto(completion: { (mData, mAlert, mDeviceOrientation) in
            viewModel.completion?(mData, mAlert, mDeviceOrientation)
        })
    }
    
    func displayLocalizeData(viewModel: HalfRealTimeScene.LocalizeData.ViewModel) {
        self.dataIsTaken = false
        print("HalfRealTimeScene.LocalizeData completion saved")
    }
    
    func displayLocalize(viewModel:  HalfRealTimeScene.Localize.ViewModel) {
        print("HalfRealTimeScene.Localize finished")
    }
    
    func displayARObjects(viewModel:  HalfRealTimeScene.ARObjects.ViewModel) {
        print("HalfRealTimeScene.ARObjects finished")
    }
    
}

extension HalfRealTimeSceneViewController: ArCameraManagerDelegate {
    
    func arCameraManager(didUpdateLocation updateLocation: CLLocation) {
        guard kfsSelectorEnabled, let arkitView = (cameraManager as? ArCameraManager)?.arKitSceneView, let camera = arkitView.session.currentFrame?.camera else {
            return
        }
        
        let request = HalfRealTimeScene.UpdateLocation.Request(location: updateLocation, cameraPosition: camera.transform.position, trackingState: camera.trackingState, state: cameraState)
        interactor?.arCameraUpdateLocation(request: request)
    }
    
    func arCameraManager(didUpdateMotion deviceMotion: CMDeviceMotion) {
        guard kfsSelectorEnabled, let arkitView = (cameraManager as? ArCameraManager)?.arKitSceneView, let camera = arkitView.session.currentFrame?.camera else {
            return
        }
        
        let request = HalfRealTimeScene.UpdateDeviceMotion.Request(deviceMotion: deviceMotion, cameraPosition: camera.transform.position, trackingState: camera.trackingState, state: cameraState)
        interactor?.arCameraUpdateDeviceMotion(request: request)
    }
    
    func arCameraManager(didActivityUpdate activity: CMMotionActivity) {
        
    }
    
    func arCameraManager(didFrameUpdate frame: ARFrame, for session: ARSession) {
        if let context = self.cameraState.arContext {
            switch self.cameraState {
            case .arkit, .preparing:
                
                // move 2d sticker
                
                if let nodesData = context.calc2DNodes(cameraPose: frame.camera.transform, ignoreVisibility: false) {
                    let orientation = self.cameraManager?.motionManager?.deviceOrientation()
                    
                    let request = HalfRealTimeScene.Markers2DMovable.Request(maybeNodes: nodesData, deviceOrientation: orientation, context: context, cameraPose: frame.camera.transform)
                    self.interactor?.move2DMarkers(request: request)
                } else {
                    let orientation = self.cameraManager?.motionManager?.deviceOrientation()
                    
                    let request = HalfRealTimeScene.Markers2DMovable.Request(maybeNodes: nil, deviceOrientation: orientation, context: context, cameraPose: frame.camera.transform)
                    self.interactor?.move2DMarkers(request: request)
                }
                
                // add traces
                if UserDefaults.arTraces ?? false {
                    self.updateArTrace(arkitView: nil, cameraPose: frame.camera.transform, cameraAngles: frame.camera.eulerAngles)
                }
                
                // put pixel buffer to context & call kfs selector
                
                switch frame.camera.trackingState {
                case .normal:
                    let buffer = PixelBufferWithPose(id: UUID().uuidString, image: frame.capturedImage, cameraPose: frame.camera.transform)
                    _ = context.put(posePixelBuffer: buffer)
                    
                    if let stopKFS = router?.dataStore?.stopKFS, !stopKFS, !dataIsTaken {
                        self.dataIsTaken = true
                        //kfsSelectorRequest(posePixelBuffer: buffer)
                        self.setSafeState(.arkit(context: context, prev: nil))
                        self.displayKfsFrameSelector(viewModel: HalfRealTimeScene.FrameSelector.ViewModel(posePixelBuffer: buffer))
                    }

                default:
                    print("[session] session not ready, state = \(frame.camera.trackingState)")
                    return
                }
                
            default:
                break
            }
        }
    }
    
    func arCameraManager(didUpdateSessionState state: ARCamera.TrackingState) {
        let request = HalfRealTimeScene.ArTrackingState.Request(trackingState: state, state: cameraState)
        interactor?.updateArTrackingState(request: request)
    }
    
    // MARK: Anchors
    
    private func createPlaneNode(_ node: SCNNode, for anchor: ARAnchor) {
        
        guard let cameraManager = self.cameraManager as? ArCameraManager, let sceneView = cameraManager.arKitSceneView, let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!)
            else {
                fatalError("Can't create plane geometry")
        }
        
        let meshNode : SCNNode
        meshGeometry.update(from: planeAnchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)
        meshNode.opacity = 0.3
        meshNode.name = meshNodeName
        
        guard let material = meshNode.geometry?.firstMaterial
            else { fatalError("ARSCNPlaneGeometry always has one material") }
        material.diffuse.contents = UIColor.green
        
        node.addChildNode(meshNode)
    }
    
    func arCameraManager(didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if showArPlane {
            createPlaneNode(node, for: anchor)
        }
        
        switch self.cameraState {
        case .arkit(let context, _):
            let request = HalfRealTimeScene.AnchorAction.Request(node: node, anchor: anchor, context: context)
            interactor?.createAnchor(request: request)
        default:
            break
        }
    }
    
    func arCameraManager(didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if showArPlane, let planeAnchor = anchor as? ARPlaneAnchor {
            if let planeGeometry = node.childNode(withName: meshNodeName, recursively: false)!.geometry as? ARSCNPlaneGeometry {
                planeGeometry.update(from: planeAnchor.geometry)
            }
        }
        
        if let context = cameraState.arContext {
            let request = HalfRealTimeScene.AnchorAction.Request(node: node, anchor: anchor, context: context)
            interactor?.updateAnchor(request: request)
        }
    }
}
