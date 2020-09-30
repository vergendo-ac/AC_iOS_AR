//
//  HalfRealTimeScenePresenter.swift
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
import ARKit

protocol HalfRealTimeScenePresentationLogic {
    
    func presentTakeNextPhoto(response: HalfRealTimeScene.TakeNextPhoto.Response)
    
    func presentNodes(response: HalfRealTimeScene.Nodes.Response)
    func presentClusters(response: HalfRealTimeScene.Clusters.Response)
    
    func presentStart(response: HalfRealTimeScene.Start.Response)
    
    func presentMarkers2DMovable(response: HalfRealTimeScene.Markers2DMovable.Response)
    func presentStickers3D(response: HalfRealTimeScene.GetStickers3D.Response)
    
    func presentArSessionStatus(response: HalfRealTimeScene.ArSessionStatus.Response)
    func presentArTrackingState(response: HalfRealTimeScene.ArTrackingState.Response)
    func presentArSessionRun(response: HalfRealTimeScene.ArSessionRun.Response)
    
    //MARK: new API
    func presentLocalize(response: HalfRealTimeScene.Localize.Response)
    func presentKfsFrameSelector(response: HalfRealTimeScene.FrameSelector.Response)
    
    func presentLocalizeData(response: HalfRealTimeScene.LocalizeData.Response)
    func presentARObjects(response: HalfRealTimeScene.ARObjects.Response)
}

class HalfRealTimeScenePresenter: HalfRealTimeScenePresentationLogic {
    
    enum RestartArSessionState {
        case start(time: TimeInterval)
        case animation(time: TimeInterval)
        
        var time: TimeInterval {
            switch self {
            case .start(let time), .animation(let time):
                return time
            }
        }
        
        var isAnimation: Bool {
            switch self {
            case .animation:
                return true
            default:
                return false
            }
        }
    }
    
    weak var viewController: HalfRealTimeSceneDisplayLogic?
    
    let nodeSize: CGSize = CGSize(width: 20, height: 20)
    private var errorsInRow = 0
    private var restartArSessionState: RestartArSessionState?
    private var animationTime: TimeInterval = 10
    private var goToStartScreenTime: TimeInterval = 30
    
    // MARK: Private
    
    private func setRestartArSessionState(_ state: RestartArSessionState?) {
        if Thread.isMainThread {
            self.restartArSessionState = state
        } else {
            DispatchQueue.main.async {
                self.restartArSessionState = state
            }
        }
    }
    
    // MARK: Do something
    
    func presentTakeNextPhoto(response: HalfRealTimeScene.TakeNextPhoto.Response) {
        let viewModel = HalfRealTimeScene.TakeNextPhoto.ViewModel(completion: response.completion)
        viewController?.displayTakeNextPhoto(viewModel: viewModel)
    }
    
    func presentNodes(response: HalfRealTimeScene.Nodes.Response) {
        let viewModel = HalfRealTimeScene.Nodes.ViewModel(
            views: response.views,
            frames: response.frames
        )
        viewController?.displayNodes(viewModel: viewModel)
    }
    
    func presentClusters(response: HalfRealTimeScene.Clusters.Response) {
        let viewModel = HalfRealTimeScene.Clusters.ViewModel(clusters: response.clusters)
        viewController?.displayClusters(viewModel: viewModel)
    }

    
    func presentStart(response: HalfRealTimeScene.Start.Response) {
        let viewModel = HalfRealTimeScene.Start.ViewModel(isStartFetching: response.isStartFetching)
        viewController?.displayStart(viewModel: viewModel)
    }
    
    private func isLocalizeError(_ error: Error?) -> Bool {
        guard let respError = error as? FetchStickersError else {
            return false
        }
        
        switch respError {
        case .serverError(let code, _):
            return code == 1
        default:
            return false
        }
    }
    
    func presentStickers3D(response: HalfRealTimeScene.GetStickers3D.Response) {
        guard let scene = response.scene, response.error == nil else {
            var status: String = ""
            var errorCode = 0
            errorsInRow += 1
            
            if let error = response.error as? FetchStickersError, let code = error.code, code > 1 {
                status = error.message ?? "Fetch sticker 3D Error"
                errorCode = code
            }
            
            if response.scene == nil {
                status = "NO 3D stickers"
            }
            
            print("[loc] sticker3D, error:\(response.error), code:\(errorCode), isMainThread:\(Thread.isMainThread)")
            
            if errorCode != 0 {
                let alert = AlertMessage(title: "Error code = \(errorCode)", message: status)
                print(alert)
            } else {
                
                if isLocalizeError(response.error), let restartState = restartArSessionState {
                    let time = Date().timeIntervalSince1970 - restartState.time
                    
                    if time > goToStartScreenTime, restartState.isAnimation {
                        setRestartArSessionState(nil)
                    } else if time > animationTime, !restartState.isAnimation {
                        setRestartArSessionState(.animation(time: restartState.time))
                    }
                }
                
                self.viewController?.restoreCameraState()
            }
            
            return
        }
        
        if let pos = scene.srvCamera?.position, length(pos) < 0.01 {
            print("[loc] sticker3D, length(pos) < 0.01")
            errorsInRow += 1
            return
        }
        
        print("[loc] displayStickers3D, isMainThread:\(Thread.isMainThread)")
        errorsInRow = 0
        setRestartArSessionState(nil)
        
        let viewModel = HalfRealTimeScene.GetStickers3D.ViewModel(scene: scene)
        self.viewController?.displayStickers3D(viewModel: viewModel)
    }
    
    func presentMarkers2DMovable(response: HalfRealTimeScene.Markers2DMovable.Response) {
        let viewModel = HalfRealTimeScene.Markers2DMovable.ViewModel(nearObjectsPins: response.nearObjectsPins)
        viewController?.displayMarkers2DMovable(viewModel: viewModel)
    }
    
    private func getArkitStateColor(state: ARCamera.TrackingState) -> UIColor {
        var color = UIColor.black
        
        switch state {
        case .notAvailable:
            color = .red
        /** Tracking is limited. See tracking reason for details. */
        case .limited(let reason):
            switch reason {
            case .insufficientFeatures:
                color = .yellow
            default:
                color = .gray
            }
        /** Tracking is normal. */
        case .normal:
            break
        }
        return color
    }
    
    private func getArkitStateMessage(state: ARCamera.TrackingState) -> String {
        var message = "normal"
        
        switch state {
        case .notAvailable:
            message = "not available"
        /** Tracking is limited. See tracking reason for details. */
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                message = "motion"
            case .initializing:
                message = "initializing"
            case .insufficientFeatures:
                message = "insufficient features"
            case .relocalizing:
                message = "relocalizing"
            default:
                message = "unknown"
            }
        /** Tracking is normal. */
        case .normal:
            break
        }
        return message
    }
    
    private func getCameraStatus(state: HalfRealCameraState) -> String {
        switch state {
        case .arkit:
            return "SCAN"
        case .preparing:
            return "REQV(\(errorsInRow))"
        default:
            return ""
        }
    }
    
    private func getScaleType(state: HalfRealCameraState) -> String {
        if let context = state.arContext {
            switch context.lastScale {
            case .none:
                return "S:-"
                     case .default:
                return "S:def"
            case .server:
                return "S:srv"
            case .usePoses:
                return "S:poses"
            case .arkit:
                return "S:arkit"
            }
        } else {
            return ""
        }
    }
    
    func presentArSessionStatus(response: HalfRealTimeScene.ArSessionStatus.Response) {
        
        let message = self.getArkitStateMessage(state: response.trackingState)
        var color = self.getArkitStateColor(state: response.trackingState)
        let cameraStatus = getCameraStatus(state: response.state)
        let scaleState = getScaleType(state: response.state)
        
        switch response.factor {
            case .degradated:
                color = .red
            case .normal:
                break
        }
        
        let status = String(format: "\(cameraStatus) \(message), \(scaleState)")
        let viewModel = HalfRealTimeScene.ArSessionStatus.ViewModel(status: status, color: color)
        //viewController?.displayArSessionStatus(viewModel: viewModel)
    }
    
    func presentArTrackingState(response: HalfRealTimeScene.ArTrackingState.Response) {
        let message = self.getArkitStateMessage(state: response.trackingState)
        let color = self.getArkitStateColor(state: response.trackingState)
        let cameraStatus = getCameraStatus(state: response.state)
        let scaleState = getScaleType(state: response.state)
        let viewModel = HalfRealTimeScene.ArSessionStatus.ViewModel(status: "\(cameraStatus) \(message) \(scaleState)", color: color)
        //viewController?.displayArSessionStatus(viewModel: viewModel)
    }
    
    func presentArSessionRun(response: HalfRealTimeScene.ArSessionRun.Response) {
        if restartArSessionState == nil {
            setRestartArSessionState(.start(time: Date().timeIntervalSince1970))
        }
        let viewModel = HalfRealTimeScene.ArSessionRun.ViewModel(options: response.options)
        viewController?.displayArSessionRun(viewModel: viewModel)
    }
    
    func presentLocalize(response: HalfRealTimeScene.Localize.Response) {
        let viewModel = HalfRealTimeScene.Localize.ViewModel()
        viewController?.displayLocalize(viewModel: viewModel)
    }
    
    func presentKfsFrameSelector(response: HalfRealTimeScene.FrameSelector.Response) {
        let viewModel = HalfRealTimeScene.FrameSelector.ViewModel(posePixelBuffer: response.posePixelBuffer)
        
        /*if Thread.isMainThread {
            DispatchQueue.global().async { [weak self] in
                self?.viewController?.displayKfsFrameSelector(viewModel: viewModel)
            }
        } else {
            viewController?.displayKfsFrameSelector(viewModel: viewModel)
        }*/
        
        self.viewController?.displayKfsFrameSelector(viewModel: viewModel)
    }
    
    func presentLocalizeData(response: HalfRealTimeScene.LocalizeData.Response) {
        let viewModel = HalfRealTimeScene.LocalizeData.ViewModel()
        viewController?.displayLocalizeData(viewModel: viewModel)
    }
    
    func presentARObjects(response: HalfRealTimeScene.ARObjects.Response) {
        let result = response.localizationResult
        
        // MARK: Localize Error
        
        if result.status.code == ._1 {
            if let restartState = restartArSessionState {
                let time = Date().timeIntervalSince1970 - restartState.time
                
                if time > goToStartScreenTime, restartState.isAnimation {
                    setRestartArSessionState(nil)
                } else if time > animationTime, !restartState.isAnimation {
                    setRestartArSessionState(.animation(time: restartState.time))
                }
            }
        
            self.viewController?.restoreCameraState()
            return
        }
        
        // MARK: No camera pose
        
        guard let pose = result.camera?.pose else {
            let error = FetchStickersError.serverError(code: HalfRealTimeScene.LocalizeError.Code.noPose.rawValue, message: "No camera pose")
            print(error)
            return
        }
        
        // MARK: No placeholders
        
        guard let placeholders = result.placeholders else {
            let error = FetchStickersError.serverError(code: HalfRealTimeScene.LocalizeError.Code.noPlaceholders.rawValue, message: "No placeholders")
            print(error)
            return
        }
        
        guard let objects = result.objects else {
            let error = FetchStickersError.serverError(code: HalfRealTimeScene.LocalizeError.Code.noObjects.rawValue, message: "No objects")
            print(error)
            return
        }
        
        let nodes = placeholders.map { Node3D.create(from: $0) }
        let serverCamera = ServerCamera.create(from: pose)
        let objectsInfo = objects.map { StickerModels.StickerData(id: $0.placeholder.placeholderId.hashValue, options: StickerOptions.sharedInstance.parse(options: $0.sticker)) }
        
        errorsInRow = 0
        setRestartArSessionState(nil)
        
        let scene = Scene3D(reconstructionId: result.reconstructionId, nodes: nodes, srvCamera: serverCamera, stickersData: objectsInfo)
        let viewModel = HalfRealTimeScene.GetStickers3D.ViewModel(scene: scene)
        self.viewController?.displayStickers3D(viewModel: viewModel)

    }
    
}
