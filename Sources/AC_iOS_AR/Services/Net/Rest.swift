//
//  RestApi.swift
//  Developer
//
//  Created by Mac on 25/02/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public class Rest {

  //MARK: REST API ASYNC
  private enum async: String {
    //Get objects
    case GetStickers = "/api/get_objects ?type=sticker&scene_format="
    case GetPlaceholders = "/api/get_objects ?type=placeholder&scene_format="
    //Add object
    case AddObject = "/api/object"
    //Series
    case UploadSeries = "/api/series" //ready
    
  }
  
    //MARK: REST API SYNC
    private enum sync: String {
        case AddSerie = "/api/add_serie"
        case UploadFiles = "/api/upload_files?name="
        case AddSticker = "/stickers/api/add_sticker"
        case GetStickers = "/stickers/api/get_stickers?scene_format="
        case AddARQuery = "/api/arkit_series"
        case BugReport = "/api/bug_report"
        case SupportedCities = "/api/supported_cities"
    }
    
    //MARK: REST PLACEHOLDERS (No VERSION API)
    private enum phs: String {
        case GetNearPlaceholders = "/rpc/get_near_placeholders?"
        case GetStickersByPlaceholders = "/rpc/get_stickers_by_placeholders?p_placeholder_ids="
    }
    
    //MARK: REST API2
    private enum api2: String {
        case baseUrl = "/api/series"
    }
    
  
    private enum sceneFormat: String {
        case None = "none"
        case Render = "render"
        case JSON2D = "json_2d"
        case JSON3D = "json_3d"
    }

    // MARK: URL
    static func getFullImageURL(serverAddress: String? = nil, imageURL: String?) -> String? {
        guard let imageURL = imageURL else { return nil }
        return self.getCurrentServerAddress(serverAddress: serverAddress) + "/" + imageURL
    }
    
  //MARK: API SYNC
    private static func getStickersUrl(serverAddress: String? = nil, format: Rest.sceneFormat) -> String {
        let url = self.getCurrentServerAddress(serverAddress: serverAddress) + Rest.sync.GetStickers.rawValue + format.rawValue
        return url
    }
    
    static func getAddSerieUrl(serverAddress: String? = nil) -> String {
        let addSerie = Rest.sync.AddSerie.rawValue
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress) + addSerie
        return url
    }
    
    static func getUploadFilesUrl(serverAddress: String? = nil, maybeSerieName: String?) -> String {
        let serieName: String = maybeSerieName ?? "DefaultSerieNameIOS"
        let uploadFiles = Rest.sync.UploadFiles.rawValue + serieName
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress) + uploadFiles
        return url
    }
    
    static func getAddStickerUrl(serverAddress: String? = nil) -> String {
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress) + Rest.sync.AddSticker.rawValue
        print(url)
        return url
    }
    
    static func getAddARQueryUrl(serverAddress: String? = nil) -> String {
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress) + Rest.sync.AddARQuery.rawValue
        return url
    }
    
    static func getBugReportUrl(serverAddress: String? = nil) -> String {
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress) + Rest.sync.BugReport.rawValue
        return url
    }

    static func getSupportedCitiesUrl(serverAddress: String? = nil) -> String {
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress) + Rest.sync.SupportedCities.rawValue
        print("getSupportedCitiesUrl", url)
        return url
    }

    //MARK: API ASYNC
    static func getUploadSeriesUrl(serverAddress: String? = nil, notification_id: String?) -> String {
        let notificationId = notification_id == nil ? "" : "?notification_id=\(notification_id!)]"
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress)
          + Rest.async.UploadSeries.rawValue
          + notificationId
        return url
    }
    
    static func getAddObjectUrl(serverAddress: String? = nil) -> String {
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress)
          + Rest.async.AddObject.rawValue
        return url
    }

    //MARK: API PLACEHOLDERS
    static func getGetNearPlaceholdersUrl(serverAddress: String? = nil, task: Task.GetNearPlaceholdersTask) -> String {
        let parameters: String = "p_latitude=\(task.latitude)&p_longitude=\(task.longitude)&p_radius=\(task.radius)"
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress)
            + Rest.phs.GetNearPlaceholders.rawValue
            + parameters
        return url
    }
    static func getStickersByPlaceholdersUrl(serverAddress: String? = nil, task: Task.GetStickersByPlaceholdersTask) -> String {
        let placeholdersIds: String = "%7B" + task.ids.joined(separator: ",") + "%7D"
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress)
            + Rest.phs.GetStickersByPlaceholders.rawValue
            + placeholdersIds
        print("url = ", url)
        //let escapedString = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        //print("escapedString = ", escapedString)
        return url
    }
    //MARK: API V2
    static func getPostSeriesV2Url(serverAddress: String? = nil, notification_id: String?) -> String {
        //POST http://<server>/api/series[?notification_id=<firebase_id>]
        let notificationId = notification_id == nil ? "" : "?notification_id=\(notification_id!)"
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress)
          + Rest.api2.baseUrl.rawValue
          + notificationId
        return url
    }
    static func getPutSeriesV2Url(serverAddress: String? = nil, task_id: String) -> String {
        //PUT http://<server>/api/series?task_id=ee822de6-6da5-411e-9184-1bca5721f523
        let taskId = "?task_id=\(task_id)"
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress)
          + Rest.api2.baseUrl.rawValue
          + taskId
        return url
    }
    static func getGetSeriesV2Url(serverAddress: String? = nil, task_id: [String]) -> String {
        //GET http://<server>/api/series?task_id=ee822de6-6da5-411e-9184-1bca5721f523[&task_id=710a6439-2644-47ad-9ddb-64ffff724adc]
        let taskIds = task_id
          .map {"task_id=\($0)"}
          .joined(separator: "&")
        let url: String = self.getCurrentServerAddress(serverAddress: serverAddress)
          + Rest.api2.baseUrl.rawValue + "?"
          + taskIds
        return url
    }

    
    static func getStickersUrl(serverAddress: String? = nil, task: Task.LoadTask) -> String {
        switch task {
        //MARK: API SYNC
            case .AddSerie(_):
                return Rest.getAddSerieUrl(serverAddress: serverAddress)
            case .UploadFiles(let uploadFilesTask):
                return Rest.getUploadFilesUrl(serverAddress: serverAddress, maybeSerieName: uploadFilesTask.collectionName)
            case .AddSticker(_):
                return Rest.getAddStickerUrl(serverAddress: serverAddress)
            case .GetStickersNone(_):
                return Rest.getStickersUrl(serverAddress: serverAddress, format: .None)
            case .GetStickersRender(_):
                return Rest.getStickersUrl(serverAddress: serverAddress, format: .Render)
            case .GetStickersJSON2D(_):
                return Rest.getStickersUrl(serverAddress: serverAddress, format: .JSON2D)
            case .GetStickersJSON3D(_):
                return Rest.getStickersUrl(serverAddress: serverAddress, format: .JSON3D)
            case .AddARQuery(_):
                return Rest.getAddARQueryUrl(serverAddress: serverAddress)
            case .BugReport(_):
                return Rest.getBugReportUrl(serverAddress: serverAddress)
            case .SupportedCities(_):
                return Rest.getSupportedCitiesUrl(serverAddress: serverAddress)
        //MARK: API ASYNC
            case .UploadSeries(let uploadSeriesTask):
                return Rest.getUploadSeriesUrl(serverAddress: serverAddress, notification_id: uploadSeriesTask.notification_id)
        case .AddObject(let addObjectTask):
                return Rest.getAddObjectUrl(serverAddress: serverAddress)
        //MARK: API PLACEHOLDERS
            case .GetNearPlaceholders(let getNearPlaceholdersTask):
                return Rest.getGetNearPlaceholdersUrl(serverAddress: serverAddress, task: getNearPlaceholdersTask)
            case .GetStickersByPlaceholders(let getStickersByPlaceholdersTask):
                return Rest.getStickersByPlaceholdersUrl(serverAddress: serverAddress, task: getStickersByPlaceholdersTask)
        //MARK: API V2
            case .PostSeriesV2(let postSeriesV2Task):
                return Rest.getPostSeriesV2Url(serverAddress: serverAddress, notification_id: postSeriesV2Task.notification_id)
            case .PutSeriesV2(let putSeriesV2Task):
                return Rest.getPutSeriesV2Url(serverAddress: serverAddress, task_id: putSeriesV2Task.task_id)
            case .GetSeriesV2(let getSeriesV2Task):
                return Rest.getGetSeriesV2Url(serverAddress: serverAddress, task_id: getSeriesV2Task.task_id)
        }
    }
    
    private static func getCurrentServerAddress(serverAddress: String? = nil) -> String {
        let storedAddress: String? = UserDefaults.currentServer
        print("storedAddress: ", storedAddress)
        var currentServerAddress: String = storedAddress ?? Servers.addresses[0]
        currentServerAddress = serverAddress ?? currentServerAddress
        print("currentServerAddress: ", currentServerAddress)
        
        if (currentServerAddress.count < 7) {
            let message: String = "WRONG server address = \(currentServerAddress)"
            print("message: ", message)
            return message
        }
        
        if (storedAddress == nil || storedAddress! != currentServerAddress) {
            UserDefaults.currentServer = currentServerAddress
        }
        
        return currentServerAddress
    }
    
}
