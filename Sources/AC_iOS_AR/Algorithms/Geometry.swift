//
//  Geometry.swift
//  myPlace
//
//  Created by Mac on 10/11/2018.
//  Copyright © 2018 Unit. All rights reserved.
//

import UIKit

class Geometry {
    
    static private func rotate(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Int {
        return Int((b.x-a.x)*(c.y-b.y)-(b.y-a.y)*(c.x-b.x))
    }
    
    static func graham(cgpoints: [CGPoint]) -> [CGPoint] {
        //https://habr.com/post/144921/
        //Graham scan
        let n = cgpoints.count
        var P = minLeftPoint(cgpoints: cgpoints)

        for i in (2 ... n-1) {
            var j = i
            while j>1 && (rotate(cgpoints[P[0]],cgpoints[P[j-1]],cgpoints[P[j]])<0) {
                P.swapAt(j-1, j)
                j -= 1
            }
        }
        
        return P.map({ (i) -> CGPoint in
            cgpoints[i]
        })

    }

    static func jarvis(cgpoints: [CGPoint]) -> [CGPoint] {
        //https://habr.com/post/144921/
        //Jarvis gift folding
        var P = minLeftPoint(cgpoints: cgpoints)
        
        var H = [P[0]]
        P.remove(at: 0)
        P.append(H[0])
         
        var right: Int = 0
         
        while true {
            right = 0
            for i in (1...P.count){
                if i < P.count && rotate(cgpoints[H.last!], cgpoints[P[right]], cgpoints[P[i]]) < 0 {
                    right = i
                }
            }
            if P[right] == H[0] {
                break
            } else {
                H.append(P[right])
                P.remove(at: right)
            }
        }
        
        return H.map({ (i) -> CGPoint in
            cgpoints[i]
        })
    }
    
    private static func minLeftPoint(cgpoints: [CGPoint]) -> [Int] {
        let n = cgpoints.count
        var P = Array(0...n-1)
        var swap: Int = 0
        for i in (1...n-1) {
            if cgpoints[P[i]].x < cgpoints[P[0]].x {
                swap = P[i]
                P[i] = P[0]
                P[0] = swap
            }
        }
        
        return P
    }
}
