//
//  ServerMessage.swift
//  myPlace
//
//  Created by Mac on 01.08.2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import SwiftyJSON

class ServerMessage {
    
    static let sharedInstance = ServerMessage()
    
    //MARK: Global
    func serverResponse(statusMessageType: NetModels.StatusMessage, completion: Task.LoadCompletion) {
       //MARK: completion.all
      
      var statusData: NetModels.StatusData = NetModels.StatusData(statusType: statusMessageType)
        statusData = statusData.setAlert(with: AlertMessage(title: "Sorry", message: statusMessageType.rawValue))
        
      switch completion {
      case .AddARQuery(let logicAddARQuery): {
        let response = NetModels.ResponseAddARQuery(
            status: NetModels.ServerStatusResponse(code: .Failed, message: statusMessageType.rawValue, title: "Error"),
            error: NSError(domain: "com.doors.error", code: -1, userInfo: [NSLocalizedDescriptionKey:statusMessageType.rawValue])
        )
        logicAddARQuery(response)
      }()
      case .UploadSeries(let logicUploadSeries): {
        let response = NetModels.ResponseUploadSeries(
          task_id: nil,
          error: NSError(domain: "com.doors.error", code: -1, userInfo: [NSLocalizedDescriptionKey:statusMessageType.rawValue])
        )
        logicUploadSeries(response)
      }()
      case .PostSeriesV2(let logicPostSeriesV2): {
        let response = NetModels.ResponsePostSeriesV2(
          task_id: nil,
          error: NSError(domain: "com.doors.error", code: -1, userInfo: [NSLocalizedDescriptionKey:statusMessageType.rawValue])
        )
        logicPostSeriesV2(response)
      }()
      case .PutSeriesV2(let logicPutSeriesV2): {
        let response = NetModels.ResponsePutSeriesV2(
            task_id: nil,
            stage: nil,
            images: nil,
            error: NSError(domain: "com.doors.error", code: -1, userInfo: [NSLocalizedDescriptionKey:statusMessageType.rawValue])
        )
        logicPutSeriesV2(response)
      }()
      case .GetSeriesV2(let logicGetSeries): {
        let response = NetModels.ResponseGetSeriesV2(
          seriesStatus: [],
          error: NSError(domain: "com.doors.error", code: -1, userInfo: [NSLocalizedDescriptionKey:statusMessageType.rawValue])
        )
        logicGetSeries(response)
      }()
      default:
        completion.empty(with: statusData)
      }
      
    }
    
    func serverResponse(isStopStickerFetching: Bool, statusMessageType: NetModels.StatusMessage, completion: Task.LoadCompletion) {
        var statusData: NetModels.StatusData = NetModels.StatusData(statusType: statusMessageType)
        
        switch completion {
        case .GetStickersNone(let logicGetStickersNone): {
            let messageResponseNone: NetModels.ResponseNone = NetModels.ResponseNone(stickers: nil, isStopStickersFetching: isStopStickerFetching)
            logicGetStickersNone(messageResponseNone, statusData)
        }()
        default:
            print("serverResponse isStopStickerFetching not supported yet \(completion.self)")
        }
        
    }
    
    func serverResponse(title: String = "", message: String, statusMessageType: NetModels.StatusMessage?, completion: Task.LoadCompletion) {
        var statusData: NetModels.StatusData = NetModels.StatusData(statusType: statusMessageType)
        let alert = AlertMessage(title: title, message: message)
        statusData = statusData.setAlert(with: alert)
        
      switch completion {
      case .AddARQuery(let logicAddARQuery): {
          let response = NetModels.ResponseAddARQuery(
              status: NetModels.ServerStatusResponse(code: .Failed, message: message, title: title),
              error: NSError(domain: statusMessageType?.rawValue ?? message, code: -1, userInfo: nil)
          )
          logicAddARQuery(response)
      }()
      case .UploadSeries(let logicUploadSeries): {
        let response = NetModels.ResponseUploadSeries(
          task_id: nil,
          error: NSError(domain: title + " " + message, code: -1, userInfo: nil)
        )
        logicUploadSeries(response)
        }()
      case .PostSeriesV2(let logicPostSeriesV2): {
        let response = NetModels.ResponsePostSeriesV2(
          task_id: nil,
          error: NSError(domain: "com.doors.error", code: -1, userInfo: [NSLocalizedDescriptionKey:title + " " + message])
        )
        logicPostSeriesV2(response)
      }()
      case .PutSeriesV2(let logicPutSeriesV2): {
        let response = NetModels.ResponsePutSeriesV2(
          task_id: nil,
          stage: nil,
          images: nil,
          error: NSError(domain: "com.doors.error", code: -1, userInfo: [NSLocalizedDescriptionKey:title + " " + message])
        )
        logicPutSeriesV2(response)
      }()
      case .GetSeriesV2(let logicGetSeries): {
        let response = NetModels.ResponseGetSeriesV2(
          seriesStatus: [],
          error: NSError(domain: "com.doors.error", code: -1, userInfo: [NSLocalizedDescriptionKey:title + " " + message])
        )
        logicGetSeries(response)
      }()
      default:
        completion.empty(with: statusData)
      }
        
    }
    
    func serverResponse(error: NSError, statusMessageType: NetModels.StatusMessage, completion: Task.LoadCompletion) {
        //MARK: completion.GetStickersJSON2D
        
        var statusData: NetModels.StatusData = NetModels.StatusData(statusType: statusMessageType)
        statusData = statusData.setMessage(with: error.localizedDescription)
        statusData = statusData.setAlert(with: AlertMessage(title: "Server response error", message: error.localizedDescription))
        
        completion.empty(with: statusData)
    }
    
    func serverResponse(statusData: NetModels.StatusData, completion: Task.LoadCompletion) {
        //MARK: completion.all
        
        var statusDataWithError = statusData
        if let text = statusData.error?.localizedDescription {
            statusDataWithError = statusDataWithError.setMessage(with: text)
        }
        
      switch completion {
      case .AddARQuery(let logicAddARQuery): {
        if let error = statusData.error {
          let response = NetModels.ResponseAddARQuery(status: nil, error: error)
          logicAddARQuery(response)
        }
      }()
      case .UploadSeries(let logicUploadSeries): {
        if let error = statusData.error {
          let response = NetModels.ResponseUploadSeries(task_id: statusData.jsonstring, error: error)
          logicUploadSeries(response)
        }
      }()
      case .PostSeriesV2(let logicPostSeriesV2): {
        if let error = statusData.error {
          let response = NetModels.ResponsePostSeriesV2(task_id: nil, error: error)
          logicPostSeriesV2(response)
        }
      }()
      case .PutSeriesV2(let logicPutSeriesV2): {
        if let error = statusData.error {
            let response = NetModels.ResponsePutSeriesV2(
                task_id: nil,
                stage: nil,
                images: nil,
                error: error
            )
            logicPutSeriesV2(response)
        }
      }()
      case .GetSeriesV2(let logicGetSeries): {
        if let error = statusData.error {
          let response = NetModels.ResponseGetSeriesV2(seriesStatus: [], error: error)
          logicGetSeries(response)
        }
      }()
      default:
        completion.empty(with: statusDataWithError)
      }
        
    }
    

    //MARK: Server Response by Type
    
    func serverResponseNone(stickers: [StickerModels.StickerData]?, serverStatus: JSON, statusData: NetModels.StatusData, completion: Task.LogicGetStickersNone) {
        let serverStatus: NetModels.ServerStatusResponse? = self.getServerStatusResponse(json: serverStatus)
        var newStatusData = statusData
        
        let gotPhotoResultNone = NetModels.ResponseNone(
            stickers: stickers,
            isStopStickersFetching: true
        )
        newStatusData = newStatusData.setResponse(with: serverStatus)
        completion(gotPhotoResultNone, newStatusData)
    }
    
    func serverResponseRender(imageURL: String?, stickers: [StickerModels.StickerShort]?, serverStatus: JSON, statusData: NetModels.StatusData, completion: Task.LogicGetStickersRender) {
        var photoURL: URL?
        if let fullImageURL = Rest.getFullImageURL(imageURL: imageURL) {
            photoURL = URL(string: fullImageURL)
        }
        
        let statusType = statusData.statusType
        let alert: AlertMessage? = (statusType != nil && statusType == .UnknownPlace) ? AlertMessage(title: statusType!.rawValue, message: "") : nil
        var newStatusData = statusData
        
        let gotPhotoResultRender = NetModels.ResponseRender(
            photoURL: photoURL, //DEPRECATED, only for unknown place & hand-tests
            stickers: stickers
        )
        completion(gotPhotoResultRender, newStatusData.setAlert(with: alert))
    }
    
    func serverResponse2D(stickers: [StickerModels.StickerData]?, nodes: [StickerModels.Node]?, serverStatus: JSON, statusData: NetModels.StatusData, completion: Task.LogicGetStickersJSON2D) {
        let serverStatus = self.getServerStatusResponse(json: serverStatus)
        var statusDataWithErrorImage = statusData
        statusDataWithErrorImage = statusDataWithErrorImage.setResponse(with: serverStatus)
        
        let gotPhotoResult2D = NetModels.Response2D(
            stickers: stickers,
            nodes: nodes
        )
        completion(gotPhotoResult2D, statusDataWithErrorImage)
    }
    
    func serverResponse3D(scene: Scene3D?, serverStatus: JSON?, statusData: NetModels.StatusData, completion: Task.LogicGetStickersJSON3D) {
        let serverStatus = self.getServerStatusResponse(json: serverStatus)
        var statusDataWithErrorImage = statusData
        
        let gotPhotoResult3D = NetModels.Response3D(code: serverStatus?.code?.rawValue, message: serverStatus?.message, scene: scene)
        completion(gotPhotoResult3D, statusDataWithErrorImage)
    }
    
    func serverResponseAddSerie(serverStatus: JSON, statusData: NetModels.StatusData, completion: Task.LogicAddSerie) {
        var title: String = "Empty server status"
        var msg: String = ""
        var isOK: Bool = false
        var statusDataWithAlert = statusData
        let maybeResponseStatus: NetModels.ServerStatusResponse? = self.getServerStatusResponse(json: serverStatus)
        
      if let responseStatus = maybeResponseStatus, let code = responseStatus.code {
            switch code {
            case .Successful:
                title = "Successful"
                msg = (responseStatus.message == nil) ? "" : responseStatus.message!
                isOK = true
            case .Failed:
                title = "Failed"
                msg = (responseStatus.message == nil) ? "Failed any reason" : responseStatus.message!
                isOK = false
            case .ServerError:
              title = "Server error"
              msg = (responseStatus.message == nil) ? "Failed by server error" : responseStatus.message!
              isOK = false
            default:
                title = "Failed"
                msg = "Unknown server code \(code), message = \((responseStatus.message == nil) ? "No server message" : responseStatus.message!)"
                isOK = false
            }
        }
        
        statusDataWithAlert = statusDataWithAlert.setAlert(with: AlertMessage(title: title, message: msg))
        
        completion(
            NetModels.ResponseAddSerie(isOK: isOK),
            statusDataWithAlert
        )
    }

    func serverResponseUploadFiles(serverStatus: JSON, statusData: NetModels.StatusData, completion: Task.LogicUploadFiles) {
        var title: String = "Empty server status"
        var msg: String = ""
        var isOK: Bool = false
        var statusDataWithAlert = statusData
        let maybeResponseStatus: NetModels.ServerStatusResponse? = self.getServerStatusResponse(json: serverStatus)
        
        if let responseStatus = maybeResponseStatus, let code = responseStatus.code {
            switch code {
            case .Successful:
                title = "Successful"
                msg = (responseStatus.message == nil) ? "" : responseStatus.message!
                isOK = true
            case .Failed:
                title = "Failed"
                msg = (responseStatus.message == nil) ? "Failed any reason" : responseStatus.message!
                isOK = false
            case .ServerError:
                title = "Server error"
                msg = (responseStatus.message == nil) ? "Failed by server error" : responseStatus.message!
                isOK = false
            default:
                title = "Failed"
                msg = "Unknown server code \(code), message = \((responseStatus.message == nil) ? "No server message" : responseStatus.message!)"
                isOK = false
            }
        }
        
        statusDataWithAlert = statusDataWithAlert.setAlert(with: AlertMessage(title: title, message: msg))
        
        completion(
            NetModels.ResponseUploadFiles(isOK: isOK),
            statusDataWithAlert
        )
    }

    func serverResponseAddSticker(serverStatus: JSON, statusData: NetModels.StatusData, completion: Task.LogicAddSticker) {
        var title: String = "Empty server status"
        var msg: String = ""
        var statusDataWithAlert = statusData
        let maybeResponseStatus: NetModels.ServerStatusResponse? = self.getServerStatusResponse(json: serverStatus)
        
        if let responseStatus = maybeResponseStatus, let code = responseStatus.code {
            let message = responseStatus.message
            switch code {
            case .Successful:
                title = "Successful"
                msg = (message == nil) ? "Sticker has been added" : message!
            case .Failed:
                title = "Failed"
                msg = (message == nil) ? "Cannot add sticker" : message!
            case .ServerError:
                title = "Server error"
                msg = (message == nil) ? "Failed by server error" : message!
            default:
                title = "Failed"
                msg = "Unknown server code \(code), message = \((message == nil) ? "No server message" : message!)"
            }
        }
        
        statusDataWithAlert = statusDataWithAlert.setAlert(with: AlertMessage(title: title, message: msg))
        
        completion(
            statusDataWithAlert
        )
    }
  
  func getServerStatusResponse(json: JSON?) -> NetModels.ServerStatusResponse? {
      if let json = json, let serverCode = json["code"].int {
        var code: NetModels.ServerStatusCode?
        switch serverCode {
          case 0:
            code = .Successful
          case 1:
            code = .Failed
          case 2:
            code = .ServerError
          default:
            code = .UnknownCode
        }
        return NetModels.ServerStatusResponse(
            code: code,
            message: json["message"].string
        )
      }
      return nil
  }
  
    //MARK: Private
    private func messageResponseAddSerie(maybeStatusCode: Int?, jsonstring: String?) -> (NetModels.ResponseAddSerie, AlertMessage?) {
        var title = ""
        var isOK: Bool = false
        
        if let statusCode = maybeStatusCode {
            switch statusCode {
            case 200:
                title = "OK"
                isOK = true
            case 500:
                title = "FAILED"
                isOK = false
            case 502:
                title = "Bad Gateway"
                isOK = false
            default:
                title = "SERVER RESPONSE"
                isOK = false
            }
        }
        
        let alert: AlertMessage? = {
            if let jsonstring = jsonstring {
                return AlertMessage(title: title, message: jsonstring)
            } else {
                return nil
            }
            
        }()
        
        return (NetModels.ResponseAddSerie (
            isOK: isOK
        ), alert)
    }
    
}
