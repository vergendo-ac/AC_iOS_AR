//
//  NetModels.swift
//  myPlace
//
//  Created by Mac on 31.07.2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation
import CoreGraphics

enum NetModels {
  
    enum StatusMessage: String {
        case ConnectingServer = "Connecting to the server"
        case TransferringImage = "Transferring the image"
        case WaitingResponse = "Waiting for the response"
        case ReceivingData = "Receiving the data"
        case ProcessingResponse = "Processing response"
        case ProcessStickers = "Process stickers"
        case GotDataFromServer = "Got data from server"
        case LoadingImages = "Loading images"
        case SavingImages = "Saving images"
        case TransferRestart = "Transfer restart"

        case SomeError = "Some error"
        case NoObjects = "No objects nearby"
        case UnknownPlace = "Unknown place"
        case NoInternetConnection = "No Internet connection"
        case NoImagetoSend = "No image to send"
        case NoServerData = "No server data"
        case ServerResponseError = "Server response error"
        case ServerAddressError = "Server address error"
        case TakePhotoError = "Take photo error"
        case NoBugReport = "No bug report"
        case NoInfo = "No info"
    }

    struct StatusData {
        let statusType: StatusMessage?
        let statusCode: Int?
        let error: NSError?
        var customMessage: String?
        var alert: AlertMessage?
        var jsonstring: String?
        var response: ServerStatusResponse?

        
        init(statusType: StatusMessage? = nil,
             statusCode: Int? = nil,
             customMessage: String? = nil,
             error: NSError? = nil,
             alert: AlertMessage? = nil,
             jsonstring: String? = nil,
             status: ServerStatusResponse? = nil
        ) {
            self.statusType = statusType
            self.statusCode = statusCode
            self.customMessage = customMessage
            self.error = error
            self.alert = alert
            self.jsonstring = jsonstring
        }
        
        mutating func setAlert(with alert: AlertMessage?) -> NetModels.StatusData {
            self.alert = alert
            return self
        }
        
        mutating func setMessage(with text: String?) -> NetModels.StatusData {
            self.customMessage = text
            return self
        }

        mutating func setResponse(with response: ServerStatusResponse?) -> NetModels.StatusData {
            self.response = response
            return self
        }
    }
    
  enum ServerStatusCode: Int, Decodable {
    case UnknownCode = -1
    case Successful = 0
    case Failed = 1
    case ServerError = 2
    
    var title: String {
        switch self {
        case .UnknownCode: return "Unknown code"
        case .Successful: return "Success"
        case .Failed: return "Failed"
        case .ServerError: return "Server error"
        }
    }
    
    var value: Int {
        return self.rawValue
    }
    
  }
  
    struct ServerStatusResponse: Decodable {
        let code: ServerStatusCode?
        let message: String?
        
        lazy var title: String = {
            switch code {
            case .some(let status):
                return status.title
            case .none:
                return "No server status code"
            }
        }()
    }
  
    enum TaskStage: String {
        case IN_QUEUE = "Wait for processing"
        case IN_PROCESS = "Make reconstruction"
        case DONE = "Process is finished"
        case UPLOAD = "Uploading"
        case UNKNOWN = "Unknown task stage"

        static func stage(for name: String) -> NetModels.TaskStage {
            switch name {
            case "IN_QUEUE":
              return .IN_QUEUE
            case "IN_PROCESS":
              return .IN_PROCESS
            case "DONE":
              return .DONE
            case "UPLOAD":
              return .UPLOAD
            default:
                return .UNKNOWN
            }
        }
    }

    struct ServerSeriesStatus {
        let stage: TaskStage
        let status: ServerStatusResponse?
        let task_id: String
        let images: [String]
    }
    
     //MARK: SYNC API
    
    struct Response3D {
        let code: Int?
        let message: String?
        let scene: Scene3D?
    }

    struct Response2D {
        let stickers: [StickerModels.StickerData]?
        let nodes: [StickerModels.Node]?
    }
    
    struct ResponseRender {
        let photoURL: URL?
        let stickers: [StickerModels.StickerShort]?
    }
    
    struct ResponseNone {
        let stickers: [StickerModels.StickerData]?
        let isStopStickersFetching: Bool
    }
    
    struct ResponseUploadFiles {
        let isOK: Bool
    }
    
    struct ResponseAddSerie {
        let isOK: Bool
    }
    
    struct ResponseAddARQuery {
        let status: ServerStatusResponse?
        let error: NSError?
    }
    
    struct ResponseBugReport {
        let status: ServerStatusResponse?
    }
    
    struct ResponseSupportedCities: Decodable {
        let id: Int
        let name: String
        let countryName: String
        let gps: GPS
    }

    //MARK: ASYNC API

    struct ResponseUploadSeries {
        let task_id: String?
        let error: NSError?
    }
    
    
    struct StickerResponse: Decodable {
        let sticker_id: String?
        let path: String?
        let sticker_text: String?
        let sticker_type: String?
        let sticker_detailed_type: String?
    }
    struct PlaceholderResponse: Decodable {
        let placeholder_id: String?
    }
    struct StickerPlaceholderResponse: Decodable {
        let sticker: StickerResponse
        let placeholder: PlaceholderResponse
    }
    struct ResponseAddObject: Decodable {
        let objects_info: [StickerPlaceholderResponse]
        let status: ServerStatusResponse
    }

    //MARK: PLACEHOLDERS STRUCTS
    struct GPS: Decodable {
        let altitude: Double?
        let latitude: Double?
        let longitude: Double?
        let radius: Double?
        
        init(altitude: Double? = nil, latitude: Double? = nil, longitude: Double? = nil, radius: Double? = nil) {
            self.altitude = altitude
            self.latitude = latitude
            self.longitude = longitude
            self.radius = radius
        }
        
        func location() -> CLLocation? {
            if let lat = self.latitude, let lon = self.longitude {
                return CLLocation(latitude: lat, longitude: lon)
            }
            return nil
        }
    }
    struct Projection {
        let path: String?
        let imageId: Int?
        let points: [CGPoint]?
    }
    struct Placeholder {
        let placeholderId: Int?
        let stickerParametersList: String?
        let gps: GPS?
        let projections: [Projection]?
    }
    struct StickerStruct: Decodable {
        let path: String?
        let rating: String?
        let urlTa: String?
        let address: String?
        let stickerId: Int?
        let phoneNumber: String?
        let stickerText: String?
        let stickerType: String?
        let priceCategory: String?
        let feedbackAmount: String?
        
        enum CodingKeys: String, CodingKey {
            case path
            case rating = "Rating"
            case urlTa = "url_ta"
            case address = "Address"
            case stickerId = "sticker_id"
            case phoneNumber = "Phone number"
            case stickerText = "sticker_text"
            case stickerType = "sticker_type"
            case priceCategory = "Price category"
            case feedbackAmount = "Feedback amount"
        }
    }
    struct PlaceholderId: Decodable {
        let placeholderId: Int
        
        enum CodingKeys: String, CodingKey {
            case placeholderId = "placeholder_id"
        }
    }

    //MARK: PLACEHOLDERS API
    struct ResponseGetNearPlaceholders {
        let placeholders: [Placeholder]?
    }
    struct ResponseGetStickersByPlaceholders: Decodable {
        let sticker: StickerStruct
        let placeholder: PlaceholderId
    }
    
    //MARK: API V2
    struct ResponsePostSeriesV2 {
        let task_id: String?
        let error: NSError?
    }
    struct ResponsePutSeriesV2 {
        let task_id: String?
        let stage: TaskStage?
        let images: [String]?
        let error: NSError?
    }
    struct ResponseGetSeriesV2 {
        let seriesStatus: [ServerSeriesStatus]
        let error: NSError?
    }

}
