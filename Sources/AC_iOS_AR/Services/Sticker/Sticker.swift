//
//  Sticker.swift
//  myPlace
//
//  Created by Mac on 31.07.2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import SwiftyJSON
import ARKit

class Sticker {
    
    static let sharedInstance = Sticker()
    let serverMessage: ServerMessage = ServerMessage.sharedInstance
    
    //MARK: API SYNC
    
    func parseNone(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicGetStickersNone) {
        print(json)
        let stickers: [StickerModels.StickerData]? = self.parseStickersInfo(json["objects_info"])
        let serverStatus: JSON = json["status"]
        self.serverMessage.serverResponseNone(stickers: stickers, serverStatus: serverStatus, statusData: statusData, completion: completion)
    }
    
    func parseRender(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicGetStickersRender) {
        let stickers: [StickerModels.StickerShort]? = self.parseStickersInfoRender(json["objects_info"])
        let serverStatus: JSON = json["status"]
        let imageURL = json["scene"].string
        
        self.serverMessage.serverResponseRender(imageURL: imageURL, stickers: stickers, serverStatus: serverStatus, statusData: statusData, completion: completion)
    }
    
    func parse2D(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicGetStickersJSON2D) {
        print(json)
        let stickers: [StickerModels.StickerData]? = self.parseStickersInfo(json["objects_info"])
        let nodes: [StickerModels.Node]? = self.parseNodesInfo(json["scene"])
        let serverStatus: JSON = json["status"]

        self.serverMessage.serverResponse2D(stickers: stickers, nodes: nodes, serverStatus: serverStatus, statusData: statusData, completion: completion)
    }
    
    func parse3D(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicGetStickersJSON3D) {
        let scene: Scene3D? = Scene3D(json: json)
        let serverStatus: JSON? = json["status"]
        self.serverMessage.serverResponse3D(scene: scene, serverStatus: serverStatus, statusData: statusData, completion: completion)
    }
    
    func parseAddSerie(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicAddSerie) {
        let serverStatus = json["status"]
        self.serverMessage.serverResponseAddSerie(serverStatus: serverStatus, statusData: statusData, completion: completion)
    }
    
    func parseUploadFiles(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicUploadFiles) {
        let serverStatus = json["status"]
        self.serverMessage.serverResponseUploadFiles(serverStatus: serverStatus, statusData: statusData, completion: completion)
    }
    
    func parseAddSticker(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicAddSticker) {
        let serverStatus = json["status"]
        self.serverMessage.serverResponseAddSticker(serverStatus: serverStatus, statusData: statusData, completion: completion)
    }
    
    func parseAddARQuery(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicAddARQuery) {
        let status = serverMessage.getServerStatusResponse(json: json["status"])
        let response = NetModels.ResponseAddARQuery(status: status, error: statusData.error)
        completion(response)
    }
    
    func parseBugReport(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicBugReport) {
        let status = serverMessage.getServerStatusResponse(json: json["status"])
        let response = NetModels.ResponseBugReport(status: status)
        completion(response, statusData)
    }
    
    func parseSupportedCities(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicSupportedCities) {
        let cities: [NetModels.ResponseSupportedCities] = self.parseCities(json)
        completion(cities, statusData)
    }
  
    //MARK: API ASYNC
    func parseUploadSeries(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicUploadSeries) {
        let task_id = json["task_id"].string
        let response = NetModels.ResponseUploadSeries(task_id: task_id, error: statusData.error)
        completion(response)
    }
    func parseAddObject(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicAddObject) {
        let responseAddObject: NetModels.ResponseAddObject? = self.parseResponseAddObject(from: json)
        completion(responseAddObject, statusData)
    }

    //MARK: API PLACEHOLDERS
    func parseGetNearPlaceholders(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicGetNearPlaceholders) {
        let placeholders: [NetModels.Placeholder]? = self.parsePlaceholders(json.array)
        let response = NetModels.ResponseGetNearPlaceholders(placeholders: placeholders)
        completion(response, statusData)
    }
    func parseGetStickersByPlaceholders(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicGetStickersByPlaceholders) {
        let stickersByPlaceholders: [NetModels.ResponseGetStickersByPlaceholders] = self.parseStickersByPlaceholders(json)
        completion(stickersByPlaceholders, statusData)
    }
    //MARK: API V2
    func parsePostSeriesV2(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicPostSeriesV2) {
        let taskId: (String?, NSError?) = self.parsePostSeriesV2Json(json)
        let response = NetModels.ResponsePostSeriesV2(task_id: taskId.0, error: taskId.1 ?? statusData.error)
        completion(response)
    }
    func parsePutSeriesV2(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicPutSeriesV2) {
        let parseRes = self.parsePutSeriesV2Json(json)
        let response = NetModels.ResponsePutSeriesV2(
            task_id: parseRes.0,
            stage: parseRes.1,
            images: parseRes.2,
            error: parseRes.3 ?? statusData.error
        )
        completion(response)
    }
    func parseGetSeriesV2(json: JSON, statusData: NetModels.StatusData, completion: Task.LogicGetSeriesV2) {
        let serverTasksStage = self.parseServerTasksStage(json.array)
        let response = NetModels.ResponseGetSeriesV2(seriesStatus: serverTasksStage, error: statusData.error)
        completion(response)
    }
    
    func getHtmlUrls(stickers: [StickerModels.StickerData]?, completion: @escaping ([URL]?, [StickerModels.StickerData]?) -> Void)  {
        if let stickers = stickers {
            var htmlUrlsArr: [URL] = []
            var stickersWithURL: [StickerModels.StickerData] = []
            for sticker in stickers {
                if let urlString = sticker.options[StickerOptions.site], let url = URL(string: urlString) {
                    htmlUrlsArr.append(url)
                    stickersWithURL.append(sticker)
                }
            }
            completion(
                (htmlUrlsArr.count > 0) ? htmlUrlsArr : nil,
                (stickersWithURL.count > 0) ? stickersWithURL : nil
            )
        } else {
            completion(nil, nil)
        }
    }
    
    func getHtmlUrls(stickers: [StickerModels.StickerShort]?) -> [URL]? {
        guard let stickers = stickers else { return nil }
        var htmlUrlsArr: [URL] = []
        for sticker in stickers {
            if let url = sticker.urlPath {
                htmlUrlsArr.append(url)
            }
        }
        return (htmlUrlsArr.count > 0) ? htmlUrlsArr : nil
    }
    
    func makeAddStickerJSON(stickerModel: StickerModels.StickerModel, filename: String) -> JSON {
        
        let points: [CGPoint] = Array(stickerModel.stickerFrame!.values)
        let stickerText: String = stickerModel.sticker.sticker_text ?? ""
        let stickerPath: String = stickerModel.sticker.path ?? ""
        let sc: CGFloat = (stickerModel.scaleCoeff == nil) ? 1.0 : stickerModel.scaleCoeff!
        let offset: CGPoint = (stickerModel.stickerOffset == nil) ? CGPoint.zero : stickerModel.stickerOffset!
        
        var pointsArr: [JSON] = []
        for p in points {
            var pcoord = JSON()
            pcoord.arrayObject = [Int((p.x - offset.x) / sc), Int((p.y - offset.y) / sc)]
            pointsArr.append(pcoord)
        }
        
        
        //JSON base structure
        var jsonArray: JSON = [
            "sticker": [
                "path":"",
                "sticker_text":""
            ],
            "placeholder": [
                "projections":[[
                    "points":[],
                    "filename":""
                    ]]
            ]
        ]
        
        jsonArray["sticker"]["path"].string = stickerPath
        jsonArray["sticker"]["sticker_text"].string = stickerText
        jsonArray["placeholder"]["projections"][0]["points"].arrayObject = pointsArr
        jsonArray["placeholder"]["projections"][0]["filename"].string = filename
        
        return jsonArray
    }
    
    func makeAddObjectJSONData(objectModel: StickerModels.ObjectModel, filename: String) -> Data? {
        var objectForUpdate = objectModel
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(objectForUpdate.add(filename: filename)) else { return nil }
        return jsonData
    }
    
    func makeARQueryJSON(poses: [StickerModels.ARCameraPose]) -> JSON {
        var arQueryJson: [JSON] = []
        for pose in poses {
            var filePose: JSON = [
                "filename": "",
                "camera_pose": []
            ]
            
            let arkitCols = pose.cameraPose.columns
            filePose["filename"].string = pose.filename
            filePose["camera_pose"].arrayObject = [
                arkitCols.0.x, arkitCols.0.y, arkitCols.0.z, arkitCols.0.w,
                arkitCols.1.x, arkitCols.1.y, arkitCols.1.z, arkitCols.1.w,
                arkitCols.2.x, arkitCols.2.y, arkitCols.2.z, arkitCols.2.w,
                arkitCols.3.x, arkitCols.3.y, arkitCols.3.z, arkitCols.3.w]
            
            if let anchorCols = pose.anchorPose?.columns {
                filePose["anchor_pose"].arrayObject = [
                anchorCols.0.x, anchorCols.0.y, anchorCols.0.z, anchorCols.0.w,
                anchorCols.1.x, anchorCols.1.y, anchorCols.1.z, anchorCols.1.w,
                anchorCols.2.x, anchorCols.2.y, anchorCols.2.z, anchorCols.2.w,
                anchorCols.3.x, anchorCols.3.y, anchorCols.3.z, anchorCols.3.w]
            }
            
            if let gravity = pose.gravity {
                filePose["gravity"].arrayObject = [gravity.x, gravity.y, gravity.z]
                
                if let anchorPose = pose.anchorPose {
                    let v0 = simd_float4(simd_float3(0, 0, 0), 1.0)
                    let v1 = simd_float4(simd_float3(gravity), 1.0)
                    let g0 = anchorPose.inverse * (pose.cameraPose * v0)
                    let g1 = anchorPose.inverse * (pose.cameraPose * v1)
                    let fixedGravity = g1 - g0
                    
                    filePose["anchor_gravity"].arrayObject = [fixedGravity.x, fixedGravity.y, fixedGravity.z]
                }
            }
            
            arQueryJson.append(filePose)
        }
        
        var cameraPoses: JSON = []
        cameraPoses.arrayObject = arQueryJson
        return cameraPoses
    }
    
    func makeDictJsonData(dict: [String:String]) -> Data? {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(dict) else { return nil }
        return jsonData
    }
    func makePostInfoJsonData(info: Task.PostSeriesInfoV2) -> Data? {
        let encoder = JSONEncoder()
        //let jsonData = try! JSONSerialization.data(withJSONObject: shootingInfo, options: [.prettyPrinted])
        guard let jsonData = try? encoder.encode(info) else { return nil }
        return jsonData
    }

    func parseStickersInfo(_ stickersInfo: JSON) -> [StickerModels.StickerData]? {
        
        var stickersArr: [StickerModels.StickerData] = []
        for (_, subJson):(String, JSON) in stickersInfo {
            
            let stickerOptions = StickerOptions.sharedInstance.parse(subJson: subJson)
            let stickerID: Int? = {
                if let sID: String = stickerOptions[StickerOptions.stickerID] {
                    return sID.hashValue
                } else {
                    return nil
                }
            }()
            
            if !(stickerOptions.isEmpty) {
                let sticker = StickerModels.StickerData(
                    id: stickerID,
                    options: stickerOptions
                )
                stickersArr.append(sticker)
            }
            
        }
        
        return (stickersArr.count > 0) ? stickersArr : nil
        
    }
    
    //MARK: Private

    private func parseNode(subJson: JSON) -> StickerModels.Node {
        let nodeDistance: Double? = subJson["node"]["distance"].double
        let nodeId: String = subJson["node"]["id"].stringValue
        let nodePoints = subJson["node"]["points"].arrayValue
        
        var nodeCGPoints: [CGPoint] = []
        
        for point in nodePoints {
            let pointArr: [Int]? = point.arrayObject as? [Int]
            if let arr = pointArr, arr.count > 1 {
                nodeCGPoints.append(CGPoint(x: arr[0] , y: arr[1]))
            }
        }
        
        return StickerModels.Node(
            distance: nodeDistance,
            id: nodeId.hashValue,
            points: nodeCGPoints
        )
    }
    
    private func parseStickersInfoRender(_ stickersInfo: JSON) -> [StickerModels.StickerShort]? {
        
        /*let jsonArray: JSON = [
         [
         "sticker":[
         "path":sampleHtmlPage1,
         "sticker_text":"StickerText1"
         ]
         ],
         [
         "sticker":[
         "path":sampleHtmlPage2,
         "sticker_text":"StickerText2"
         ]
         ]
         ]*/
        
        var stickersArr: [StickerModels.StickerShort] = []
        for (_, subJson):(String, JSON) in stickersInfo {
            
            let urlString = subJson["sticker"]["path"].stringValue
            let stickerText = subJson["sticker"]["sticker_text"].stringValue
            
            if (urlString.count > 0 || stickerText.count > 0) {
                let sticker = StickerModels.StickerShort(
                    urlPath: (urlString.count > 0) ? URL(string: urlString) : nil,
                    text: (stickerText.count > 0) ? stickerText : nil
                )
                stickersArr.append(sticker)
            }
        }
        
        return (stickersArr.count > 0) ? stickersArr : nil
    }
    
    private func parseNodesInfo(_ nodesInfo: JSON) -> [StickerModels.Node]? {
        
        var nodesArr: [StickerModels.Node] = []
        for (_, subJson):(String, JSON) in nodesInfo {
            nodesArr.append(self.parseNode(subJson: subJson))
        }
        
        return (nodesArr.count > 0) ? nodesArr : nil
    }
    
  private func parseServerTasksStage(_ tasksInfo: [JSON]?) -> [NetModels.ServerSeriesStatus] {
    if let tasksInfo = tasksInfo, tasksInfo.count > 0 {
      return tasksInfo.map { (info) -> NetModels.ServerSeriesStatus in
        let stage = NetModels.TaskStage.stage(for: info["stage"].stringValue)
        let status = serverMessage.getServerStatusResponse(json: info["status"])
        let task_id = info["task_id"].stringValue
        let images: [String] = (info["images"].arrayObject as? [String]) ?? []
        
        return NetModels.ServerSeriesStatus(
          stage: stage,
          status: status,
          task_id: task_id,
          images: images
        )
      }
    } else {
      return []
    }
  }
    
    private func parsePlaceholders(_ placeholdersInfo: [JSON]?) -> [NetModels.Placeholder]? {
        guard let placeholdersInfo = placeholdersInfo else { return nil }
        guard placeholdersInfo.count > 0 else { return nil }

            
        return placeholdersInfo.map { (info) -> NetModels.Placeholder in
            
            let placeHolderJson = info["placeholder"]
            
            let placeholder_id: Int? = placeHolderJson["placeholder_id"].int
            let sticker_parameters_list: String? = placeHolderJson["sticker_parameters_list"].string
            
            let gps: (JSON?) -> NetModels.GPS? = { gpsJson in
                guard let gpsJson = gpsJson else { return nil }
                return NetModels.GPS(
                    altitude: gpsJson["altitude"].double,
                    latitude: gpsJson["latitude"].double,
                    longitude: gpsJson["longitude"].double,
                    radius: gpsJson["radius"].double
                )
            }
            
            let projections: ([JSON]?) -> [NetModels.Projection]? = { projJsonArr in
                guard let projJsonArr = projJsonArr else { return nil }
                
                let points: ([JSON]?) -> [CGPoint]? = { pointsJsonArr in
                    guard let pointsJsonArr = pointsJsonArr else { return nil }
                    let cgPoints: [CGPoint] = pointsJsonArr.reduce(into: []) { (acc, points) in
                        if let arr = points.arrayObject as? [Int], arr.count > 1 {
                            acc.append(CGPoint(x: arr[0] , y: arr[1]))
                        }
                    }
                    return cgPoints
                }
                
                return projJsonArr.map { (projJson) -> NetModels.Projection in
                    return NetModels.Projection(
                        path: projJson["path"].string,
                        imageId: projJson["image_id"].int,
                        points: points(projJson["points"].array)
                    )
                }
                
            }

            let placeHolder = NetModels.Placeholder(
                placeholderId: placeholder_id,
                stickerParametersList: sticker_parameters_list,
                gps: gps(placeHolderJson["gps"]),
                projections: projections(placeHolderJson["projections"].array)
            )
            
            return placeHolder
        }
            
    }
    
    private func parsePostSeriesV2Json(_ json: JSON) -> (String?, NSError?) {
        if let taskId = json["task_id"].string {
            return (taskId, nil)
        } else {
            let error: NSError = NSError(domain: "com.doors.error", code: -2, userInfo: [NSLocalizedDescriptionKey: json.stringValue])
            return (nil, error)
        }
    }
    
    private func parsePutSeriesV2Json(_ json: JSON) -> (task_id: String?, stage: NetModels.TaskStage?, images: [String]?, error: NSError?) {
        if let task_id = json["task_id"].string {
            let stage = NetModels.TaskStage.stage(for: json["stage"].stringValue)
            let images = json["images"].arrayObject as? [String]
            return (task_id, stage, images, nil)
        } else {
            let error: NSError = NSError(domain: "com.doors.error", code: -2, userInfo: [NSLocalizedDescriptionKey: json.stringValue])
            return (nil, nil, nil, error)
        }
    }
    
    private func parseCities(_ json: JSON) -> [NetModels.ResponseSupportedCities] {
        let decoder = JSONDecoder()
        guard let jsonData = try? decoder.decode([NetModels.ResponseSupportedCities].self, from: json.rawData()) else { return [] }
        return jsonData
    }
    
    func parseStickersByPlaceholders(_ json: JSON) -> [NetModels.ResponseGetStickersByPlaceholders] {
        let decoder = JSONDecoder()
        guard let jsonData = try? decoder.decode([NetModels.ResponseGetStickersByPlaceholders].self, from: json.rawData()) else { return [] }
        return jsonData
    }
    
    func parseResponseAddObject(from json: JSON) -> NetModels.ResponseAddObject? {
        let decoder = JSONDecoder()
        guard let jsonData = try? decoder.decode((NetModels.ResponseAddObject).self, from: json.rawData()) else { return nil }
        return jsonData
    }
  
}
