//
//  ArCameraContext+ext.swift
//  YaPlace
//
//  Created by Andrei Okoneshnikov on 08.05.2020.
//  Copyright © 2020 SKZ. All rights reserved.
//

import Foundation
import ARKit

struct Node3dPoses {
    let nodeId: String
    let points: [(name: String, position: simd_float3)]
}

extension ArCameraContext {
    
    func rebaseStickerToAnchorNode(_ node: SCNNode, anchor: ARAnchor, scene: Scene3D) {
        guard let nodeId = anchor.name, let _ = anchor as? ArStickerAnchor else {
            return
        }
        
        if let items = scene.arfNodes[nodeId] {
            for item in items {
                let pos = item.worldPosition
                node.addChildNode(item)
                item.worldPosition = pos
            }
            
            for (index, item) in items.enumerated() {
                var next = items[0]
                if index < items.count - 1 {
                    next = items[index + 1]
                }
                
                if let line = item.childNodes.first(where: {$0 is ARFLineNode}) as? ARFLineNode {
                    line.to = item.convertPosition(next.position, from: node)
                }
            }
        }
        
        print("[anchor] rebase sticker to anchor node, name:\(anchor.name ?? "-")")
    }
    
    func rebaseSceneToMainNode(_ mainNode: Node3D, scenePose: float4x4? = nil) -> Node3dPoses? {
        guard let arkitView = arkitView, let scene = currentScene else {
            return nil
        }
        
        guard let nodes = scene.arfNodes[mainNode.id], nodes.count > 0 else {
            return nil
        }
        
        self.setMainNode(mainNode)
        
        let points: [simd_float3] = [nodes[1].simdWorldPosition, nodes[2].simdWorldPosition, nodes[0].simdWorldPosition]
        
        if let tf_s0_a = scenePose ?? calculateStickerTransform(points: points) {
            
            // MARK: store old sticker points world position
            var oldPosition: [String: simd_float3] = [:]
            for (nid, items) in scene.arfNodes {
                for item in items {
                    let sid = "\(nid)_\(item.name ?? "")"
                    oldPosition[sid] = item.simdWorldPosition
                }
            }
            
            arkitView.scene.rootNode.addChildNode(scene)
            scene.simdWorldTransform = tf_s0_a
            print("[anchor] trnsform scene tf_s0_a:\(tf_s0_a.position)")
            
            for (nid, items) in scene.arfNodes {
                for item in items {
                    //let pos = item.worldPosition
                    scene.addChildNode(item)
                    let sid = "\(nid)_\(item.name ?? "")"
                    item.simdWorldPosition = oldPosition[sid]!
                }
                
                for (index, item) in items.enumerated() {
                    var next = items[0]
                    if index < items.count - 1 {
                        next = items[index + 1]
                    }
                    
                    if let line = item.childNodes.first(where: {$0 is ARFLineNode}) as? ARFLineNode {
                        line.to = item.convertPosition(next.position, from: scene)
                    }
                }
            }
        }
        
        let nodePoints = nodes.map {($0.name!, $0.simdWorldPosition)}
        return Node3dPoses(nodeId: mainNode.id, points: nodePoints)
    }
    
    func fixScene(anchor: ARAnchor, nodePoses: Node3dPoses) -> Node3dPoses? {
        guard let scene = currentScene, nodePoses.nodeId == mainNode?.id else {
            return nil
        }
        
        guard let nodes = scene.arfNodes[nodePoses.nodeId], nodes.count > 2, nodes[1].name == nodePoses.points[1].name, nodes[2].name == nodePoses.points[2].name, nodes[0].name == nodePoses.points[0].name else {
            print("[anchor] !!! invalid anchor")
            return nil
        }
        
        var nodePoints: [(name: String, position: simd_float3)] = []
        for item in nodePoses.points {
            if item.name == anchor.name {
                nodePoints.append((item.name, anchor.transform.position))
            } else {
                nodePoints.append(item)
            }
        }

        let points: [simd_float3] = [nodePoints[1].position, nodePoints[2].position, nodePoints[0].position]

        if let tf_s0_a = calculateStickerTransform(points: points) {
            scene.simdWorldTransform = tf_s0_a
            print("[anchor] fix points anchor")
        }
        
        return Node3dPoses(nodeId: nodePoses.nodeId, points: nodePoints)
    }
    
    func fixScenePosition(anchor: ARAnchor, scenePose: float4x4? = nil) {
        guard let scene = currentScene, let nodeId = mainNode?.id, let nodes = scene.arfNodes[nodeId] else {
            return
        }
        
        var pts: [simd_float3] = []
        for node in nodes {
            if node.name == anchor.name {
                pts.append(anchor.transform.position)
            } else {
                pts.append(node.simdWorldPosition)
            }
        }
        
        let points: [simd_float3] = [pts[1], pts[2], pts[0]]
        
        if let tf_s0_a = scenePose ?? calculateStickerTransform(points: points) {
            scene.simdWorldTransform = tf_s0_a
        }
    }
    
    func createStickerAnchorPose(nodes: [SCNNode]) -> simd_float4x4? {
        var center = simd_float3(0, 0, 0)
        for node in nodes {
            center += node.simdWorldPosition
        }
        
        if nodes.count > 0 {
            center = center/Float(nodes.count)
            return simd_float4x4(rotation: nodes[0].simdWorldTransform.upperLeft3x3, position: center)
        }
        return nil
    }
    
    func findNearestObjects(cameraPose: simd_float4x4, prev: ScreenNearObjectsPins) -> ScreenNearObjectsPins {
        guard let arkitView = arkitView, let scene = currentScene, scene.arfNodes.count > 0 else {
            return (.none, .none)
        }
        
        let mat = SCNMatrix4(cameraPose)
        let cameraDirection = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        let cameraPosition = SCNVector3(mat.m41, mat.m42, mat.m43)
        let size = UIScreen.main.bounds
        
        // update 2d stickers
        var nodesData: [(id: String, angle: Float, left: Bool, point: simd_float2)] = []
        
        for (k, items) in scene.arfNodes {
            guard items.count > 3 else {
                continue
            }
            
            var center = SCNVector3()
            
            for item in items {
                center += item.worldPosition
            }
            
            center = center / Float(items.count)
            let centerProj = arkitView.projectPoint(center)
            var center2d = simd_float2(centerProj.x, centerProj.y)
          
            let pc = center - cameraPosition
            let n1 = length(simd_float2(cameraDirection.x, cameraDirection.z))
            let n2 = length(simd_float2(pc.x, pc.z))
            
            let angle: Float = acos((cameraDirection.x*pc.x + cameraDirection.z*pc.z)/(n1*n2))
            
            let vec = SCNVector3.vecmul(a: SCNVector3(cameraDirection.x, 0, cameraDirection.z), b: SCNVector3(pc.x, 0, pc.z))
            
            let isLeft = vec.y > 0
            
            center2d.y = max(0, min(Float(size.height) - 40, center2d.y))
            //print("[near] angle:\(angle), cx2d:\(center2d), cx3d:\(center), n1:\(n1), n2:\(n2)")
            nodesData.append((k, angle, isLeft, center2d))
        }
        
        nodesData.sort { $0.angle < $1.angle }
        let leftItem = nodesData.first(where: { $0.left })
        let rightItem = nodesData.first(where: { !$0.left })
        //let leftAngle = leftItem != nil ? String(format: "%.2f", leftItem!.angle) : "-"
        //let rightAngle = rightItem != nil ? String(format: "%.2f", rightItem!.angle) : "-"
        let angleLimit: Float = .pi/6
        
        if let left = leftItem, let right = rightItem {
            var leftTop = CGFloat(left.point.y)
            var rightTop = CGFloat(right.point.y)
            
            if left.angle > .pi/2 - angleLimit, left.angle < .pi/2 + angleLimit, let id = prev.left.id, id == left.id {
                leftTop = prev.left.top ?? leftTop
            }
            
            if right.angle > .pi/2 - angleLimit, right.angle < .pi/2 + angleLimit, let id = prev.right.id, id == right.id {
                rightTop = prev.right.top ?? rightTop
            }
            
            return (
                .left(
                    id: left.id,
                    y: leftTop,
                    count: nodesData.filter({ $0.left }).count,
                    all: nodesData.count,
                    categoryPin: scene.getStickerTypeById(left.id) ?? .other),
                .right(
                    id: right.id,
                    y: rightTop,
                    count: nodesData.filter({ !$0.left }).count,
                    all: nodesData.count,
                    categoryPin: scene.getStickerTypeById(right.id) ?? .other))
        } else if let left = leftItem {
            var leftTop = CGFloat(left.point.y)
            
            if left.angle > .pi/2 - angleLimit, left.angle < .pi/2 + angleLimit, let id = prev.left.id, id == left.id {
                leftTop = prev.left.top ?? leftTop
            }
            
            return (
                .left(
                    id: left.id,
                    y: leftTop,
                    count: nodesData.filter({ $0.left }).count,
                    all: nodesData.count,
                    categoryPin: scene.getStickerTypeById(left.id) ?? .other),
                .none)
        } else if let right = rightItem {
            var rightTop = CGFloat(right.point.y)
            
            if right.angle > .pi/2 - angleLimit, right.angle < .pi/2 + angleLimit, let id = prev.right.id, id == right.id {
                rightTop = prev.right.top ?? rightTop
            }
            
            return (
                .none,
                .right(
                    id: right.id,
                    y: rightTop,
                    count: nodesData.filter({ !$0.left }).count,
                    all: nodesData.count,
                    categoryPin: scene.getStickerTypeById(right.id) ?? .other))
        }
        
        return (.none, .none)
    }
}
