//
//  Task.swift
//  MyPlaceLibIOS
//
//  Created by Mac on 29.08.2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

public class Task {
    
    //MARK: API SYNC COMPLETION
    typealias LogicGetImage = (UIImage?, NetModels.StatusData?) -> Void
    typealias LogicAddSerie = (NetModels.ResponseAddSerie?, NetModels.StatusData?) -> Void
    typealias LogicUploadFiles = (NetModels.ResponseUploadFiles?, NetModels.StatusData?) -> Void
    typealias LogicAddSticker = (NetModels.StatusData?) -> Void
    typealias LogicGetStickersNone = (NetModels.ResponseNone?, NetModels.StatusData?) -> Void
    typealias LogicGetStickersRender = (NetModels.ResponseRender?, NetModels.StatusData?) -> Void
    typealias LogicGetStickersJSON2D = (NetModels.Response2D?, NetModels.StatusData?) -> Void
    typealias LogicGetStickersJSON3D = (NetModels.Response3D?, NetModels.StatusData) -> Void
    typealias LogicAddARQuery = (NetModels.ResponseAddARQuery?) -> Void
    typealias LogicBugReport = (NetModels.ResponseBugReport?, NetModels.StatusData?) -> Void
    typealias LogicSupportedCities = ([NetModels.ResponseSupportedCities], NetModels.StatusData?) -> Void
    //MARK: API ASYNC COMPLETION
    typealias LogicUploadSeries = (NetModels.ResponseUploadSeries?) -> Void
    typealias LogicAddObject = (NetModels.ResponseAddObject?, NetModels.StatusData?) -> Void
    //MARK: API PLACEHOLDERS COMPLETION
    typealias LogicGetNearPlaceholders = (NetModels.ResponseGetNearPlaceholders?, NetModels.StatusData?) -> Void
    typealias LogicGetStickersByPlaceholders = ([NetModels.ResponseGetStickersByPlaceholders], NetModels.StatusData?) -> Void
    
    //MARK: API V2
    typealias LogicPostSeriesV2 = (NetModels.ResponsePostSeriesV2) -> Void
    typealias LogicPutSeriesV2 = (NetModels.ResponsePutSeriesV2) -> Void
    typealias LogicGetSeriesV2 = (NetModels.ResponseGetSeriesV2) -> Void


  
  enum LoadCompletion {
    //MARK: API SYNC
    case AddSerie(LogicAddSerie)
    case UploadFiles(LogicUploadFiles)
    case AddSticker(LogicAddSticker)
    case GetStickersNone(LogicGetStickersNone)
    case GetStickersRender(LogicGetStickersRender)
    case GetStickersJSON2D(LogicGetStickersJSON2D)
    case GetStickersJSON3D(LogicGetStickersJSON3D)
    case AddARQuery(LogicAddARQuery)
    case BugReport(LogicBugReport)
    case SupportedCities(LogicSupportedCities)
    //MARK: API ASYNC
    case UploadSeries(LogicUploadSeries)
    case AddObject(LogicAddObject)
    //MARK: API PLACEHOLDERS
    case GetNearPlaceholders(LogicGetNearPlaceholders)
    case GetStickersByPlaceholders(LogicGetStickersByPlaceholders)
    //MARK: API V2
    case PostSeriesV2(LogicPostSeriesV2)
    case PutSeriesV2(LogicPutSeriesV2)
    case GetSeriesV2(LogicGetSeriesV2)

    internal func empty(with statusData: NetModels.StatusData?) {
      switch self {
        //MARK: API SYNC
        case .AddSerie(let logicAddSerie): {
            logicAddSerie(nil, statusData)
        }()
        case .UploadFiles(let logicUploadFiles): {
            logicUploadFiles(nil, statusData)
        }()
        case .AddSticker(let logicAddSticker): {
            logicAddSticker(statusData)
        }()
        
        case .GetStickersNone(let logicGetStickersNone): {
            logicGetStickersNone(nil, statusData)
        }()
        case .GetStickersRender(let logicGetStickersRender): {
            logicGetStickersRender(nil, statusData)
        }()
        case .GetStickersJSON2D(let logicGetStickersJSON2D): {
            logicGetStickersJSON2D(nil, statusData)
        }()
        case .GetStickersJSON3D(let logicGetStickersJSON3D): {
            logicGetStickersJSON3D(nil, statusData!)
        }()
        case .AddARQuery(let logicAddARQuery): {
            let response = NetModels.ResponseAddARQuery(status: nil, error: statusData?.error)
            logicAddARQuery(response)
        }()
        case .BugReport(let logicBugReport): {
            logicBugReport(nil, statusData)
        }()
        case .SupportedCities(let logicSupportedCities): {
            logicSupportedCities([], statusData)
        }()
        //MARK: API ASYNC
        case .UploadSeries(let logicUploadSeries): {
            let response = NetModels.ResponseUploadSeries(task_id: statusData?.jsonstring, error: statusData?.error)
            logicUploadSeries(response)
        }()
        case .AddObject(let logicAddObject): {
            logicAddObject(nil, statusData)
        }()
        //MARK: API PLACEHOLDERS
        case .GetNearPlaceholders(let logicGetNearPlaceholders): {
            logicGetNearPlaceholders(nil, statusData)
        }()
        case .GetStickersByPlaceholders(let logicGetStickersByPlaceholders): {
            logicGetStickersByPlaceholders([], statusData)
        }()
        //MARK: API V2
        case .PostSeriesV2(let logicPostSeriesV2): {
            let response = NetModels.ResponsePostSeriesV2(task_id: nil, error: statusData?.error)
            logicPostSeriesV2(response)
        }()
        case .PutSeriesV2(let logicPutSeriesV2): {
            let response = NetModels.ResponsePutSeriesV2(task_id: nil, stage: nil, images: nil, error: statusData?.error)
            logicPutSeriesV2(response)
        }()
        case .GetSeriesV2(let logicGetSeries): {
            let response = NetModels.ResponseGetSeriesV2(seriesStatus: [], error: statusData?.error)
            logicGetSeries(response)
        }()

      }
    }
  }
  
    //MARK: API SYNC
    struct AddSerieTask {
        let images: [ImageModels.Image]?
    }
    struct UploadFilesTask {
        let collectionName: String?
        let images: [ImageModels.Image]?
    }
    struct AddStickerTask {
        let image: ImageModels.Image?
        let stickerModel: StickerModels.StickerModel?
    }
    struct GetStickersNoneTask {
        let image: ImageModels.Image?
    }
    struct GetStickersRenderTask {
        let image: ImageModels.Image?
    }
    struct GetStickersJSON2DTask {
        let image: ImageModels.Image?
    }
    struct GetStickersJSON3DTask {
        let image: ImageModels.Image?
    }
    struct AddARQueryTask {
        let images: [ImageModels.Image]
        let poses: [StickerModels.ARCameraPose]
    }
    struct BugReportTask {
        let report: [String:String]
        let justName: String //just name, without any extension
    }
    struct SupportedCitiesTask {
    }
    //MARK: API ASYNC
    struct UploadSeriesTask {
        let notification_id: String? //If specified the client would get push notification when series process is finished
        let images: [ImageModels.Image]?
    }
    struct AddObjectTask {
        let image: ImageModels.Image?
        let objectModel: StickerModels.ObjectModel?
    }
    //MARK: API PLACEHOLDERS
    struct GetNearPlaceholdersTask {
        let latitude: Double
        let longitude: Double
        let radius: Double //meters
    }
    struct GetStickersByPlaceholdersTask {
        let ids: [String]
    }
    //MARK: API V2
    
    /// PostSeriesV2Task:
    /// ' info' dictionary should contain these fields:
    /// [
    /// "user": "user@mail.com",
    /// "device": "phone model",
    /// "client": "app description (name, version, build)",
    /// "name": "series name",
    /// "daytime": "day" | "evening" | "night",
    /// "passages_count": 2
    /// ]
    /// Library will check presence of all fields. Later possible to fill some fields automatically: "device", "client"
    struct PostSeriesInfoV2: Encodable {
        let user: String // "user@mail.com",
        let device: String // "phone model"
        let client: String //"app description (name, version, build)",
        let name: String // "series name",
        let daytime: String // "day" | "evening" | "night",
        let passages: [Passage]
        
        init(userMail: String, seriesName: String, dayTime: String, passages: [Passage] = []) {
            let appVersion = Bundle.main.versionNumber
            let appName = Bundle.main.appName
            let buildNumber = Bundle.main.buildNumber
            let deviceModel = UIDevice.modelName
            
            self.user = userMail
            self.device = deviceModel
            self.client = "\(appName), \(appVersion), \(buildNumber)"
            self.name = seriesName
            self.daytime = dayTime
            self.passages = passages
        }
        
        var allFieldsHaveData : Bool {
            get {
                !(
                    self.user.isEmpty &&
                    self.device.isEmpty &&
                    self.client.isEmpty &&
                    self.name.isEmpty &&
                    self.daytime.isEmpty &&
                    self.passages.isEmpty
                )
            }
        }
        
        struct Passage: Encodable {
            let style: String
            let points: [[PassagePoint]]
        }
        
        struct PassagePoint: Encodable {
            let filename: String
            let camera: Camera?
        }
        
        struct Camera: Encodable {
            let pose: CameraPose
            let intrinsics: CameraIntrinsics
        }
        
        struct CameraPose: Encodable {
            let position: CameraPosition
            let orientation: CameraOrientation
        }
        
        struct CameraPosition: Encodable {
            let x: Float
            let y: Float
            let z: Float
        }

        struct CameraOrientation: Encodable {
            let w: Float
            let x: Float
            let y: Float
            let z: Float
        }

        struct CameraIntrinsics: Encodable {
            /** Focal length */
            public var fx: Float
            /** Focal length */
            public var fy: Float
            /** Principal point */
            public var cx: Float
            /** Principal point */
            public var cy: Float

            public init(fx: Float, fy: Float, cx: Float, cy: Float) {
                self.fx = fx
                self.fy = fy
                self.cx = cx
                self.cy = cy
            }
        }
        
    }
    struct PostSeriesV2Task {
        let notification_id: String? //If specified the client would get push notification when series process is finished
        let info: PostSeriesInfoV2
    }
    struct PutSeriesV2Task {
        let task_id: String
        let images: [ImageModels.Image]?
    }
    struct GetSeriesV2Task {
        let task_id: [String]
        let user_id: String?
    }

    
  enum LoadType {
      case Upload
      case Download
  }
  
  enum LoadTask {
    //MARK: API SYNC
    case AddSerie(AddSerieTask)
    case UploadFiles(UploadFilesTask)
    case AddSticker(AddStickerTask)
    case GetStickersNone(GetStickersNoneTask)
    case GetStickersRender(GetStickersRenderTask)
    case GetStickersJSON2D(GetStickersJSON2DTask)
    case GetStickersJSON3D(GetStickersJSON3DTask)
    case AddARQuery(AddARQueryTask)
    case BugReport(BugReportTask)
    case SupportedCities(SupportedCitiesTask)
    //MARK: API ASYNC
    case UploadSeries(UploadSeriesTask)
    case AddObject(AddObjectTask)
    //MARK: API PLACEHOLDERS
    case GetNearPlaceholders(GetNearPlaceholdersTask)
    case GetStickersByPlaceholders(GetStickersByPlaceholdersTask)
    //MARK: API V2
    case PostSeriesV2(PostSeriesV2Task)
    case PutSeriesV2(PutSeriesV2Task)
    case GetSeriesV2(GetSeriesV2Task)
  }
  
}
