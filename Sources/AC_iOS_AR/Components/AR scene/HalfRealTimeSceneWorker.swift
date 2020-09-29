//
//  HalfRealTimeSceneWorker.swift
//  YaPlace
//
//  Created by Rustam Shigapov on 11/09/2019.
//  Copyright (c) 2019 SKZ. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import ARKit
import SwiftyJSON

class HalfRealTimeSceneWorker {
    
    let contentOperationQueue = OperationQueue()
    fileprivate let image: Image = Image.sharedInstance
    fileprivate let point: Point = Point.sharedInstance
    
    func doImageDataRequest(image: ImageModels.Image?, completion: @escaping (ImageModels.Image?, NetModels.StatusData?) -> Swift.Void) {
        self.image.doImageDataRequest(image: image, completion: completion)
    }
    
    //MARK: calc points!!!!
    func calcNodesTriplePoints(maybeNodes: [StickerModels.Node]?, imageSize: CGSize, windowSize: CGSize, maybeDeviceOrientation: UIDeviceOrientation?) -> PointModels.TripleCentralPoints? {
        return self.point.calcNodesTriplePoints(maybeNodes: maybeNodes, imageSize: imageSize, windowSize: windowSize, maybeDeviceOrientation: maybeDeviceOrientation)
    }
    
    func calcAR2DCentralPoints(maybeNodes: [StickerModels.Node]?, windowSize: CGSize, maybeDeviceOrientation: UIDeviceOrientation?) -> ([Int:CGPoint]?, [Int:Int]?) {
        return self.point.calcAR2DCentralPoints(maybeNodes: maybeNodes, windowSize: windowSize, maybeDeviceOrientation: maybeDeviceOrientation)
    }
    
    func nodeInBounds(p: CGPoint, windowSize: CGSize) -> Bool {
        return self.point.nodeInBounds(p: p, windowSize: windowSize)
    }
    
    func nodesInBounds(arrP: [CGPoint], windowSize: CGSize) -> Bool {
        return self.point.nodesInBounds(arrP: arrP, windowSize: windowSize)
    }
    
    func makeStickerNodes(points: [Int : PointModels.DistantPoint], maybeStickers: [Int : StickerModels.StickerData]?) -> [StickerModels.StickerNode]? {
        return self.point.makeStickerNodes(points: points, maybeStickers: maybeStickers)
    }
    
    //MARK: ALG2
    func updateStickersPosition(views: [StickerSceneView], pinViewSize: CGSize) -> [StickerSceneView] {
        print(views.count)
        let sortedViews = views.sorted { (v1, v2) -> Bool in
            return v2.frame.origin.x > v1.frame.origin.x
        }
        
        var currentPosition: StickerPosition = .up
        
        sortedViews.forEach { (view) in
            currentPosition =  currentPosition.position(p: view.stickerCentralPoint, size: pinViewSize)
            view.stickerPosition = currentPosition
        }
        
        let upViews = sortedViews.filter { $0.stickerPosition == .up }
        let downViews = sortedViews.filter { $0.stickerPosition == .down }
        
        return chessStickers(views: upViews, .up) + chessStickers(views: downViews, .down)
    }
    
    //MARK: ALG1
    func chessStickers(views: [StickerSceneView], _ stickerPosition: StickerPosition) -> [StickerSceneView] {
        print(views.count)
        let sortedViews = views.sorted { (v1, v2) -> Bool in
            return v2.frame.origin.x > v1.frame.origin.x
        }
        
        var previousIndex: Int = 0
        var nextIndex: Int = 1
        var heightDiff: CGFloat = 0.0
        var levels: Int = 0
        let internalGap: CGFloat = 8.0
    
        while nextIndex < sortedViews.count {
            if sortedViews[nextIndex].leftSide < sortedViews[previousIndex].rightSide {
                levels += 1
                
                heightDiff += sortedViews[nextIndex - 1].textBlockSize.height + internalGap
                sortedViews[nextIndex].offsetY = heightDiff
                nextIndex += 1
            } else {
                previousIndex = nextIndex + levels
                levels = 0
                heightDiff = stickerPosition.commonOffset //TODO: hard code, remove after Apple release!
                sortedViews[nextIndex].offsetY = heightDiff
                nextIndex = previousIndex + 1
            }
        }

        return sortedViews
    }
    
    //MARK: ALG3
    func levelStickers(views: [StickerSceneView], pinViewSize: CGSize) -> [StickerSceneView] {
        let levelSize = pinViewSize.height / 7.0
        var levels: [Bool] = [false, false, false, false, false, false, false]
        var dU: Int = 0
        var dD: Int = 0
        var pos: StickerPosition = .up
        
        let checkNearestEmptyLevel: (Int) -> (CGFloat, StickerPosition) = { currentPinLevel in
            var dL: Int = -1
            
            while dL < 0 {
                
                if -1 < (dU - 1), levels.count > dU {
                    dU -= 1
                    if !levels[dU] {
                        dL = dU
                        pos = .up
                        levels[dL] = true
                    }
                } else if -1 < dD, levels.count > (dD + 1) {
                    dD += 1
                    if !levels[dD] {
                        dL = dD
                        pos = .down
                        levels[dL] = true
                    }
                } else {
                    break
                }
                    
            }
            
            return (CGFloat(dL), pos)
        }
        
        let getLevelOffset: (CGFloat, CGFloat) -> (CGFloat, StickerPosition) = { y, vH2 in
            let currentPinLevel: Int = Int(floor(y / levelSize)) //to the minor side
            dU = currentPinLevel
            dD = currentPinLevel
            let (lvl, pos) = checkNearestEmptyLevel(currentPinLevel)
            switch pos {
            case .up:
                return (levelSize * (lvl + 0.5) - vH2, pos)
            case .down:
                return (pinViewSize.height - (levelSize * (lvl + 0.5) + vH2), pos)
            }
            
        }
        
        let placeView: (StickerSceneView) -> Void = { view in
            let (offset, pos) = getLevelOffset(view.stickerCentralPoint.y, view.textBlockSize.height / 2.0)
            view.offsetY = offset
            view.stickerPosition = pos
        }
        
        views.forEach(placeView)
        
        print("levels: ", levels)
        
        return views
    }
    
    func parse2DTest(completion: Task.LogicGetStickersJSON2D) {
        if let asset = NSDataAsset(name: "fourStickerScaleTest"),
            let str = String(decoding: asset.data, as: UTF8.self) as String?,
            let realJSON: JSON = JSON(parseJSON: str) as JSON? {
            let statusData = NetModels.StatusData(statusType: .GotDataFromServer)
            Sticker.sharedInstance.parse2D(json: realJSON, statusData: statusData, completion: completion)
        }
    }
}

extension HalfRealTimeSceneWorker {
    
    private func scanRect(startRect: CGRect, rects: [CGRect], validH: CGFloat, isTopDirection: Bool) -> [CGRect] {
        
        guard startRect.height > validH else {
            return []
        }
        
        var validRects: [CGRect] = [startRect]
        
        for rect in rects {
            var updatedRects: [CGRect] = []
            for validRect in validRects {
                if validRect.intersects(rect) {
                    let result = startRect.intersection(rect)
                    
                    // bottom part
                    if result.maxY < validRect.maxY, validRect.maxY - result.maxY > validH {
                        updatedRects.append(CGRect(x: startRect.minX, y: result.maxY, width: startRect.width, height: validRect.maxY - result.maxY))
                    }
                    
                    // upper part
                    if result.minY > validRect.minY, result.minY - validRect.minY > validH {
                        updatedRects.append(CGRect(x: startRect.minX, y: validRect.minY, width: startRect.width, height: result.minY - validRect.minY))
                    }
                } else {
                    updatedRects.append(validRect)
                }
            }
            validRects = updatedRects
        }
        return validRects
    }
    
    // MARK: New algorithm
    func alignStickers(views: [StickerSceneView], pinViewSize: CGSize) -> [StickerSceneView] {
        
        var rects: [CGRect] = []
        
        // MARK: append pins
        for view in views {
            let center = view.stickerCentralPoint
            let size = StickerSceneView.distanceToScale(distance: view.distance)
            let rect = CGRect(x: center.x - size.width/2, y: center.y - size.height/2, width: size.width, height: size.height)
            rects.append(rect)
        }
        
        // MARK: top
        
        for view in views {
            let center = view.stickerCentralPoint
            
            if center.y < view.stickerCentralPoint.y, view.isHidden {
                continue
            }
            
            let gap: CGFloat = 5.0
            let pinSize = StickerSceneView.distanceToScale(distance: view.distance)
            let width = view.frame.width
            let topRect = CGRect(x: center.x - width/2, y: 0, width: width, height: center.y - pinSize.height/2)
            let bottomRect = CGRect(x: center.x - width/2, y: center.y + pinSize.height/2, width: width, height: pinViewSize.height - (center.y + pinSize.height/2))
            let validH = view.textBlockSize.height + gap
            
            let topRects = self.scanRect(startRect: topRect, rects: rects, validH: validH, isTopDirection: true).sorted(by: {$0.minY > $1.minY})
            let bottomRects = self.scanRect(startRect: bottomRect, rects: rects, validH: validH, isTopDirection: false).sorted(by: {$0.minY < $1.minY})
            
            if let top = topRects.first, let bottom = bottomRects.first {
                //if (center.y - top.maxY <= bottom.minY - center.y) || view.stickerPosition == .up {
                if view.stickerPosition == .up {
                    view.stickerPosition = .up
                    view.offsetY = top.maxY - validH
                } else {
                    view.stickerPosition = .down
                    view.offsetY = pinViewSize.height - (bottom.minY + validH)
                }
            } else if let top = topRects.first {
                view.stickerPosition = .up
                view.offsetY = top.maxY - validH
            } else if let bottom = bottomRects.first {
                view.stickerPosition = .down
                view.offsetY = pinViewSize.height - (bottom.minY + validH)
            } else {
                //print("[test] no place")
                continue
            }
            
            if view.stickerPosition == .up {
                rects.append(
                    CGRect(x: center.x - width/2, y: view.offsetY, width: width, height: validH)
                )
            } else {
                rects.append(
                    CGRect(x: center.x - width/2, y: pinViewSize.height - view.offsetY - view.textBlockSize.height, width: width, height: validH)
                )
            }
            
        }
        return views
    }
}

// Load video

extension HalfRealTimeSceneWorker {
    
    /**
     https://stackoverflow.com/questions/30363502/maintaining-good-scroll-performance-when-using-avplayer
     */
    func loadSource(url: URL, completion: @escaping (AVPlayer?) -> ()) {
        //self.status = .Unknown

        let operation = BlockOperation()
        operation.addExecutionBlock { () -> Void in
            // create the asset
            let asset = AVURLAsset(url: url, options: nil)
            // load values for track keys
            let keys = ["tracks", "duration"]
            
            asset.loadValuesAsynchronously(forKeys: keys) {
                // Loop through and check to make sure keys loaded
                
                for key in keys {
                    var error: NSError?
                    let keyStatus: AVKeyValueStatus = asset.statusOfValue(forKey: key, error: &error)
                    if keyStatus == .failed {
                        print("Failed to load key: \(key)")
                        completion(nil)
                        return
                    }
                    else if keyStatus != .loaded {
                        print("Warning: Ignoring key status: \(keyStatus), for key: \(key), error: \(error)")
                        completion(nil)
                        return
                    }
                }
                
                if operation.isCancelled == false, let _ = self.createCompositionFromAsset(asset: asset) {
                    //let playerItem = AVPlayerItem(asset: asset)
                    let playerItem = AVPlayerItem(asset: asset)
                    // create the player
                    let player = AVPlayer(playerItem: playerItem)
                    completion(player)
                }
            }
        }
        
        // add operation to the queue
        
        self.contentOperationQueue.addOperation(operation)
    }

    func createCompositionFromAsset(asset: AVAsset, repeatCount: UInt8 = 16) -> AVMutableComposition? {
        let composition = AVMutableComposition()
        let timescale = asset.duration.timescale
        let duration = asset.duration.value
        let editRange = CMTimeRangeMake(start: CMTimeMake(value: 0, timescale: timescale), duration: CMTimeMake(value: duration, timescale: timescale))
        
        do {
            try composition.insertTimeRange(editRange, of: asset, at: composition.duration)
            
            for _ in 0 ..< repeatCount - 1 {
                try composition.insertTimeRange(editRange, of: asset, at: composition.duration)
            }
        
        } catch {
            print("Failed createCompositionFromAsset")
            return nil
        }
        
        return composition
    }
}