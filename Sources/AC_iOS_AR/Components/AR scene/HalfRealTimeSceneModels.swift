//
//  HalfRealTimeSceneModels.swift
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
import CoreLocation.CLLocation
import ARKit
import CoreMotion

typealias ScreenNearObjectsPins = (left: HalfRealTimeScene.NearObjectsPinType, right: HalfRealTimeScene.NearObjectsPinType)

indirect enum HalfRealCameraState {
    case arkit(context: ArCameraContext, prev: HalfRealCameraState?)
    case normal(prev: HalfRealCameraState?)
    case preparing(prev: HalfRealCameraState, startAnimation: Bool = false)
    
    var isArkit: Bool {
        switch self {
        case .arkit:
            return true
        default:
            return false
        }
    }
    
    var arContext: ArCameraContext? {
        switch self {
        case .arkit(let context, _):
            return context
        case .preparing(let prev, _):
            return prev.arContext
        default:
            return nil
        }
    }
}

enum HalfRealTimeScene {
    
    enum NearObjectsPinType {
        case left(id: String, y: CGFloat, count: Int, all: Int, categoryPin: InfoStickerCategory)
        case right(id: String, y: CGFloat, count: Int, all: Int, categoryPin: InfoStickerCategory)
        case none
        
        var isNone: Bool {
            switch self {
            case .none:
                return true
            default:
                return false
            }
        }
        
        var title: String {
            switch self {
            case .none:
                return ""
            case .left(_, _, let count, let all, _), .right(_, _, let count, let all, _):
                return count > 1 ? "\(all) Objects Near You" : "The Object Near You"
            }
        }
        
        var text: String {
            switch self {
            case .none:
                return ""
            case .left(_, _, let count, _, _), .right(_, _, let count, _, _):
                return count > 1 ? "Turn your device around to see all of them." : "Turn your device to see it."
            }
        }
        
        var color: UIColor? {
            switch self {
            case .left(_, _, _, _, let pin), .right(_, _, _, _, let pin):
                return pin.color
            default:
                return nil
            }
        }
        
        var image: UIImage? {
            switch self {
            case .left(_, _, _, _, let pin), .right(_, _, _, _, let pin):
                return pin.image
            default:
                return nil
            }
        }
        
        var top: CGFloat? {
            switch self {
            case .left(_, let y, _, _, _), .right(_, let y, _, _, _):
                return y
            default:
                return nil
            }
        }
        
        var id: String? {
            switch self {
            case .left(let id, _, _, _, _), .right(let id, _, _, _, _):
                return id
            default:
                return nil
            }
        }
    }
    
    enum SceneState {
        case Animation
        case Photo
        case ShowSticker
        case WaitScanPress
        case NoSensors
    }

    // MARK: Use cases
    
    enum BackToStart {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum FrameSelectorParams {
        struct Request {
            let cameraPose: simd_float4x4
            let stickerPoses: [simd_float4x4]
        }
        
        struct Response {
            
        }
        
        struct ViewModel {
            
        }
    }
    
    /*enum SavePhoto {
        struct Request {
            let image: ImageModels.Image?
            let deviceOrientation: UIDeviceOrientation?
            let currentLocation: CLLocation?
        }
        struct Response {
        }
        struct ViewModel {
        }
    }*/
    
    enum GetStickers {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum GotPhoto {
        struct Request {
        }
        struct Response {
            let response: (NetModels.Response2D)?
        }
        struct ViewModel {
        }
    }
    
    enum FrameSelector {
        struct Request {
            let posePixelBuffer: PixelBufferWithPose
        }
        
        struct Response {
            let posePixelBuffer: PixelBufferWithPose
        }
        
        struct ViewModel {
            let posePixelBuffer: PixelBufferWithPose
        }
    }
    
    enum GetStickers3D {
        struct Request {
            let imageInfo: ImageModels.Image
        }
        struct Response {
            let scene: Scene3D?
            let error: Error?
        }
        struct ViewModel {
            let scene: Scene3D
        }
    }
    
    enum Stickers {
        struct Request {
        }
        struct Response {
            let stickers: [StickerModels.StickerData]?
        }
        struct ViewModel {
            let stickersText: String?
            let stickersNum: Int?
        }
    }
    
    enum Nodes {
        struct Request {
            let maybeNodes: [StickerModels.Node]?
            let maybeStickers: [StickerModels.StickerData]?
            let deviceOrientation: UIDeviceOrientation?
        }
        struct Response {
            let views: [StickerSceneView]?
            let frames: [StickerMarkerFrameSceneView]?
        }
        struct ViewModel {
            let views: [StickerSceneView]?
            let frames: [StickerMarkerFrameSceneView]?
        }
    }
    
    enum Clusters {
        struct Request {
        }
        struct Response {
            let clusters: [StickerSceneView]?
        }
        struct ViewModel {
            let clusters: [StickerSceneView]?
        }
    }
    
    enum NodesNum {
        struct Request {
            let leftPointsNum: Int?
            let centralPointsNum: Int?
            let rightPointsNum: Int?
        }
        struct Response {
            let leftPointsNum: Int?
            let centralPointsNum: Int?
            let rightPointsNum: Int?
        }
        struct ViewModel {
            let leftPointsNum: String?
            let centralPointsNum: String?
            let rightPointsNum: String?
        }
    }
    
   enum TakeNextPhoto {
        struct Request {
            let completion: ((Data?, NSError?, UIDeviceOrientation?) -> Void)
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum StickerView {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum StickerTableView {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum Settings {
        struct Request {
            let pinViewSize: CGSize
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum StartStickersFetching {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum StopStickersFetching {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum Stop {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum Start {
        struct Request {
            let arBackView: UIView?
        }
        struct Response {
        }
        struct ViewModel {
        }
    }

    enum Alert {
        struct Request {
        }
        struct Response {
            let message: AlertMessage
        }
        struct ViewModel {
            let message: AlertMessage
        }
    }
    
    enum DeInit {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum ButtonsNewVerticalPlace {
        struct Request {
            let newY: CGFloat?
        }
        struct Response {
            let newY: CGFloat?
        }
        struct ViewModel {
            let newY: CGFloat?
        }
    }
    
    enum StopServerRequest {
        struct Request {
        }
        struct Response {
            let isRequestStopped: Bool
        }
        struct ViewModel {
            let isRequestStopped: Bool
        }
    }
    
    enum RemoveObserver {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum ShowStatus {
        struct Request {
            let status: NetModels.StatusData?
        }
        struct Response {
            let status: NetModels.StatusData
        }
        struct ViewModel {
            let alert: AlertMessage?
        }
    }
    
    enum Markers2DMovable {
        struct Request {
            let maybeNodes: [StickerModels.Node]?
            let deviceOrientation: UIDeviceOrientation?
            let context: ArCameraContext
            let cameraPose: simd_float4x4
        }
        struct Response {
            let nearObjectsPins: ScreenNearObjectsPins
        }
        struct ViewModel {
            let nearObjectsPins: ScreenNearObjectsPins
        }
    }
    
    enum Clear2DMarkers {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum JustSavePhoto {
        struct Request {
            let image: ImageModels.Image?
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum ShowSettings {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum ShowMap {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum ShowCList {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }

    enum AnchorAction {
        struct Request {
            let node: SCNNode
            let anchor: ARAnchor
            let context: ArCameraContext
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum MainNode {
        struct Request {
            let prevScene: Scene3D
            let context: ArCameraContext
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum HandleAnchors {
        struct Request {
            let cameraManager: ArCameraManager
            let context: ArCameraContext
            let scene: Scene3D
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum DistanceType: String {
        case gps = "GPS"
        case acc = "ACC"
    }
    
    enum DegradationFactor {
        case normal(factor: Float)
        case degradated(factor: Float)
        
        var value: Float {
            switch self {
            case .normal(let f):
                return f
            case .degradated(let f):
                return f
            }
        }
    }
    
    enum UpdateLocation {
        
        struct Request {
            let location: CLLocation
            let cameraPosition: simd_float3
            let trackingState: ARCamera.TrackingState
            let state: HalfRealCameraState
        }

    }
    
    enum UpdateDeviceMotion {
        struct Request {
            let deviceMotion: CMDeviceMotion
            let cameraPosition: simd_float3
            let trackingState: ARCamera.TrackingState
            let state: HalfRealCameraState
        }
        
        struct Response {
        }
    }
    
    enum ArTrackingState {
        struct Request {
            let trackingState: ARCamera.TrackingState
            let state: HalfRealCameraState
        }
        
        struct Response {
            let trackingState: ARCamera.TrackingState
            let state: HalfRealCameraState
        }
    }
    
    enum ArSessionStatus {
        
        struct Response {
            let factor: DegradationFactor
            let disatnceType: DistanceType
            let trackingState: ARCamera.TrackingState
            let state: HalfRealCameraState
        }
        
        struct ViewModel {
            let status: String
            let color: UIColor
        }
    }
    
    enum ArSessionRun {
        
        struct Request {
            let options: ARSession.RunOptions
        }
        
        struct Response {
            let options: ARSession.RunOptions
        }
        
        struct ViewModel {
            let options: ARSession.RunOptions
        }
    }

    enum ArTrace {
        
        struct Request {
            let arkitView: ARSCNView?
            let cameraPose: simd_float4x4?
            let cameraAngles: simd_float3?
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }

    enum ArCreature {
        struct Request {
            let arkitView: ARSCNView?
            let superView: UIView?
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }

    enum StartArCamera {
        struct Request {
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum CleanUpUI {
        struct Request {
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }

    enum State {
        struct Request {
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum Filter {
        struct Request {
            let filterStickerType: InfoStickerCategory?
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum VideoSticker {
        struct Request {
            let context: ArCameraContext
            let arkitView: ARSCNView
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum ClearArContent {
        struct Request {
            let cameraManager: ArCameraManager
            let clearAnchors: Bool
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }

    enum LocalizeError {
        
        enum Code: Int {
            case noLocalization = 1
            case noPose = 2
            case noPlaceholders = 3
            case noObjects = 4
        }

        struct Response {
            let error: Error
        }
        
        struct ViewModel {
            let error: Error
        }
    }
    
    enum Localize {
        struct Request {
            let image: ImageModels.Image
            let intrinsics: simd_float3x3
            let cameraPose: Pose
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }

    enum ARObjects {
        struct Request {
            let localizationResult: LocalizationResult
        }
        
        struct Response {
            let localizationResult: LocalizationResult
        }
        
        struct ViewModel {
            let scene: Scene3D
        }
    }
    

    enum LocalizeData {
        struct Request {
            let completion: ((_ imageData: Data?, _ location: CLLocation?, _ photoInfo: [String:Any]?, _ pose: Pose?) -> Void)?
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum Delegate {
        struct Request {
            let stickerDelegate: StickerDelegate?
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum Delete {
        struct Request {
            let stickerID: Int
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }
    
    enum StickerFilters {
        struct Request {
            let filters: [String:Bool]
        }
        
        struct Response {
        }
        
        struct ViewModel {
        }
    }

}
