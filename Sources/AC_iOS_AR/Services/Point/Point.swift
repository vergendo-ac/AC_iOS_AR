//
//  Point.swift
//  myPlace
//
//  Created by Mac on 31.07.2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class Point {
    
    static let sharedInstance = Point()
    
    func calcNodesTriplePoints(maybeNodes: [StickerModels.Node]?, imageSize: CGSize, windowSize: CGSize, maybeDeviceOrientation: UIDeviceOrientation?) -> PointModels.TripleCentralPoints? {
        
        print("ARSize i w o: \(imageSize) \(windowSize) \(maybeDeviceOrientation!)")
        
        var leftPoints: [Int:PointModels.DistantPoint] = [:]
        var centralPoints: [Int:PointModels.DistantPoint] = [:]
        var rightPoints: [Int:PointModels.DistantPoint] = [:]
        var scaledFramePoints: [Int:PointModels.DistantFramePoints] = [:]
        var allPoints: [Int:PointModels.DistantPoint] = [:]
        
        //let defaultImageSize = CGSize(width: 1080, height: 1920)
        let needToScale = !(UserDefaults.arCameraEnabled ?? false)
        
        let scaleOffsetPoint = scaleOffset(windowSize: windowSize, imageSize: imageSize)
        
        //print("ARSize scaleOffsetPoint = \(scaleOffsetPoint)")
        
        if let nodes = maybeNodes {
            for node in nodes {
                let key = node.id!
                if let point = self.calcNodeCentralPoint(node: node) {
                    
                        //let scaledPoint = point.mulXY(to: xCoef, and: yCoef)
                    let scaledPoint = needToScale ? point.mul(to: scaleOffsetPoint.coeff).add(to: scaleOffsetPoint.offset) : point

                    if let nodesPoints = node.points {
                        for nodePoint in nodesPoints {
                            //let scaledNodePoint = nodePoint.mulXY(to: xCoef, and: yCoef)
                            let scaledNodePoint = needToScale ? nodePoint.mul(to: scaleOffsetPoint.coeff).add(to: scaleOffsetPoint.offset) : nodePoint
                            let positionedNodePoint = self.setPointPosition(p: scaledNodePoint, windowSize: windowSize, maybeDeviceOrientation: maybeDeviceOrientation)
                            var frameDistantPoints: PointModels.DistantFramePoints = scaledFramePoints[key] ?? (node.distance, [])
                            frameDistantPoints.1.append(positionedNodePoint)
                            scaledFramePoints[key] = frameDistantPoints
                        }
                    }
                    
                    let positionedPoint = self.setPointPosition(p: scaledPoint, windowSize: windowSize, maybeDeviceOrientation: maybeDeviceOrientation)
                    allPoints[key] = (node.distance, positionedPoint)
                    
                    switch self.triplePoint(p: positionedPoint, windowSize: windowSize) {
                    case -1:
                        leftPoints[key] = (node.distance, positionedPoint)
                    case 0:
                        centralPoints[key] = (node.distance, positionedPoint)
                    case 1:
                        rightPoints[key] = (node.distance, positionedPoint)
                    default:
                        print("Can't triple point : \((node.distance, positionedPoint))")
                    }
                    
                }
            }
            
        }
        
        
        return (leftPoints.count == 0 && centralPoints.count == 0 && rightPoints.count == 0) ?
            nil :
            PointModels.TripleCentralPoints(
                leftPoints: leftPoints,
                centralPoints: centralPoints,
                rightPoints: rightPoints,
                framePoints: scaledFramePoints,
                allPoints: allPoints
        )
    }
    
    func calcAR2DCentralPoints(maybeNodes: [StickerModels.Node]?, windowSize: CGSize, maybeDeviceOrientation: UIDeviceOrientation?) -> ([Int:CGPoint]?, [Int:Int]?) {
        if let nodes = maybeNodes {
            let tuple: ([Int:CGPoint], [Int:Int]) = nodes.reduce(into: ([:], [:])) { (acc, node) in
                if let point = self.calcNodeCentralPoint(node: node) {
                    
                    var (centralPoints, nums): ([Int:CGPoint], [Int:Int]) = acc
                    centralPoints[node.id!] = point
                    
                    let pointPos = self.triplePoint(p: point, windowSize: windowSize)
                    nums[pointPos] = (nums[pointPos] ?? 0) + 1
                    
                    acc = (centralPoints, nums)
                }
            }
            return (tuple.0, tuple.1)
        } else {
            return (nil, nil)
        }
    }
    
    private func calcNodeCentralPoint(node: StickerModels.Node) -> CGPoint? {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var nP: CGFloat = 0
        if let points = node.points {
            nP = CGFloat(points.count)
            for point in points {
                x += point.x
                y += point.y
            }
            return CGPoint(
                x: (nP == 0) ? 0 : x / nP,
                y: (nP == 0) ? 0 : y / nP
            )
        } else {
            return nil
        }
    }
    
    private func setPointPosition(p: CGPoint, windowSize: CGSize, maybeDeviceOrientation: UIDeviceOrientation?) -> CGPoint {
        let deviceOrientation: UIDeviceOrientation = maybeDeviceOrientation ?? .portrait
        let scY = windowSize.height / windowSize.width
        let scX = windowSize.width / windowSize.height
        switch deviceOrientation {
        case .landscapeLeft:
            return CGPoint(x: windowSize.width - p.y / scX, y: p.x * scY)
        case .portrait:
            return p
        case .landscapeRight:
            return CGPoint(x: p.y / scX, y: windowSize.height - p.x * scY)
        case .portraitUpsideDown:
            let newP = CGPoint(x: windowSize.width - p.x, y: windowSize.height - p.y)
            return newP
        default:
            return p
        }
    }
    
    private func triplePoint(p: CGPoint, windowSize: CGSize) -> Int {
        guard p.x > 0 else { return -1 }
        guard p.x < windowSize.width else { return 1 }
        guard p.y > 0 && p.y <= windowSize.height else {
            if (p.x < windowSize.width / 2) { return -1 } else { return 1 }
        }
        return 0
    }
    
    func nodeInBounds(p: CGPoint, windowSize: CGSize) -> Bool {
        return self.triplePoint(p: p, windowSize: windowSize) == 0
    }
    
    func nodesInBounds(arrP: [CGPoint], windowSize: CGSize) -> Bool {
        return arrP.reduce(into: false) { $0 = $0 || nodeInBounds(p: $1, windowSize: windowSize) }
    }
    
    func makeStickerNodes(points: [Int : PointModels.DistantPoint], maybeStickers: [Int : StickerModels.StickerData]?) -> [StickerModels.StickerNode]? {
        if let stickers = maybeStickers {
            var stickerNodes: [StickerModels.StickerNode] = []
            for (key, point) in points {
                if let stickerData = stickers[key] {
                    stickerNodes.append(
                        StickerModels.StickerNode(
                            id: key,
                            distantPoint: point,
                            stickerData: stickerData
                        )
                    )
                }
            }
            return (stickerNodes.count > 0) ? stickerNodes : nil
        } else {
            print("makeStickerNodes: count of centralPoints & stickers are unequal. \(points.count) !== \(maybeStickers!.count)")
            return nil
        }
    }
    
    private func scaleOffset(windowSize: CGSize, imageSize: CGSize) -> (coeff: CGFloat, offset: CGPoint) {
        let xCoef = windowSize.width / imageSize.width
        let yCoef = windowSize.height / imageSize.height
        let finalCoef = max(xCoef, yCoef)
        let offset = CGPoint(
            x: (windowSize.width - imageSize.width * finalCoef) / 2.0,
            y: (windowSize.height - imageSize.height * finalCoef) / 2.0
        )
        return (finalCoef, offset)
    }
    
}
