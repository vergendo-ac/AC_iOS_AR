//
//  GooglePoly.swift
//  MyPlaceLibIOS
//
//  Created by Mac on 23.01.2020.
//  Copyright © 2020 Lammax. All rights reserved.
//

// Google POLY API key = AIzaSyCw8upH8OA8OpXThk9RHWBScMQHL4HORYw

import Foundation

/*
import PolyKit
import SceneKit
import SceneKit.ModelIO
import ModelIO
 */

class GooglePolyHelper {
    
    public static let sharedInstance = GooglePolyHelper()

    private let apiKey: String = "AIzaSyCw8upH8OA8OpXThk9RHWBScMQHL4HORYw"
    
    //need to use PolyKit framework
    //https://github.com/fromkk/PolyKit
    //https://medium.com/@fromkk/use-poly-api-for-arkit-e053d352f1f7
    //there is some headache with including binary of that framework. locally all is working good, but impossible to share app with TestFlight, something with code-signing
    
    /*
    func addPolyKitModel() -> SCNNode? {
       let polyApi = PolyAPI(apiKey: apiKey)
       /*polyApi.asset("1hkwylnuWpC") { (result) in
           switch result {
           case .success(let asset):
               self.showPolyPreview(with: asset)
           case .failure(let error):
               print(error.localizedDescription)
           }
       }*/
       let query = PolyAssetsQuery(keywords: "Castle", format: .obj)
       polyApi.assets(with: query) { (result) in
           switch result {
           case .success(let assets):
               if let assets = assets.assets, assets.count > 0 {
                   self.makePolyNodes(assets: assets, readyNodes: []) {
                        return self.showPolyNodes(polyNodes: $0)
                    }
               } else {
                   print("polyApi.assets 0 objects")
                    return nil
               }
           case .failure(_):
               print("polyApi.assets error")
                return nil
           }
       }
    }
    private func makePolyNodes(assets: [PolyKit.PolyAsset], readyNodes: [SCNNode], completion: @escaping ([SCNNode]) -> Void) {
       if assets.count > 0 && readyNodes.count < 5 {
           
           self.getPolyNode(with: assets.first!) { pn in
               let leftToLoad = Array(assets.dropFirst())
               print("leftToLoad \(leftToLoad.count)")
               if let pn = pn {
                   print("Have node")
                   self.makePolyNodes(assets: leftToLoad, readyNodes: readyNodes + [pn], completion: completion)
               } else {
                   print("Nil node")
                   self.makePolyNodes(assets: leftToLoad, readyNodes: readyNodes, completion: completion)
               }
           }
       } else {
           completion(readyNodes)
       }
    }

    private func getPolyNode(with asset: PolyKit.PolyAsset, completion: ((SCNNode?) -> Void)? = nil) {
       asset.downloadObj { (result) in
         switch result {
         case .success(let localUrl):
           let mdlAsset = MDLAsset(url: localUrl)
           mdlAsset.loadTextures()
           let polyNode = SCNNode(mdlObject: mdlAsset.object(at: 0))
           completion?(polyNode)
         case .failure(let error):
           print(error.localizedDescription)
           completion?(nil)
         }
       }
    }
    private func showPolyNodes(polyNodes: [SCNNode]) -> SCNNode {
        //as a table
     
       let tableSideSize: Float = 2.0 //meters
       let nodesCount = polyNodes.count
       let nodesInARow: Int = Int((sqrt(Double(nodesCount)).rounded(.up)))
       let nodeSize: Float = tableSideSize / Float(nodesInARow)
       let normalSize = SCNVector3(nodeSize, nodeSize, nodeSize)

       let tableNode = SCNNode()
       tableNode.position = SCNVector3(0, 0, -1)
       
       var i: Int = 0
       var row: Int = 0, col: Int = 0
       while i < nodesCount {
           if col < nodesInARow {
               let polyNode = polyNodes[i]
               
               let maxNodeSize = polyNode.boundingSphere.radius * 2.0
               polyNode.scale = normalSize.scale(from: maxNodeSize)
               
               polyNode.position = SCNVector3(
                   Float(col) * nodeSize - tableSideSize / 2.0,
                   Float(row) * nodeSize - tableSideSize / 2.0,
                   0
               )
               tableNode.addChildNode(polyNode)
               col += 1
               i += 1
           } else {
               col = 0
               row += 1
           }
       }
        return tableNode
       
    }
 */
    
    
}
