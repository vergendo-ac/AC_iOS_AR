//
//  ARFVideoNode.swift
//  YaPlace
//
//  Created by Andrei Okoneshnikov on 20.07.2020.
//  Copyright © 2020 SKZ. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class ARFVideoNode: ARFNode {
    private let scn = SCNBox(width: 0, height: 0, length: 0.005, chamferRadius: 0)
    private let fore = SCNMaterial()
    private let back = SCNMaterial()
    private var _player: AVPlayer?
    private var _thumb: UIImage?
    private var notificationObserver: NSObjectProtocol?
    private(set) var stopped = false
    
    static let defColor: UIColor = UIColor.clear
    static let defTransparency: CGFloat = 1.0

    override init() {
        super.init()
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    init(width: CGFloat, height: CGFloat, player: AVPlayer?, thumb: UIImage, name: String? = nil) {
        super.init()
        _player = player
        _thumb = thumb
        back.diffuse.contents = UIColor.white
        scn.width = width
        scn.height = height
        initialize()
        setMaterials()
    }
    
    deinit {
        
    }
    
    func cleanup() {
        if let o = self.notificationObserver {
            self.notificationObserver = nil
            NotificationCenter.default.removeObserver(o)
        }
        player?.pause()
        player?.seek(to: CMTime.zero)
        player = nil
    }
    
    func play() {
        stopped = false
        if player?.timeControlStatus == .paused {
            player?.isMuted = false
            player?.play()
        }
    }
    
    func pause() {
        if player?.timeControlStatus == .playing {
            player?.isMuted = true
            player?.pause()
        }
    }
    
    func stop() {
        pause()
        stopped = true
    }
    
    func updateWidth(_ width: CGFloat) {
        let ratio = self.width/self.height
        self.width = width
        self.height = width / ratio
    }
    
    private func initialize()  {
        self.geometry = scn
    }
    
    private func setMaterials()  {
        if let p = player, let url = p.currentItem?.asset as? AVURLAsset, let movieTrack = url.tracks(withMediaType: AVMediaType.video).first {
            let sz = movieTrack.naturalSize
            
            p.seek(to: CMTime.zero)
            p.isMuted = false
            let needRotate = _thumb!.size.width < _thumb!.size.height && sz.width > sz.height
            
            let sceneSz = CGSize(width: needRotate ? sz.height : sz.width,
                                 height: needRotate ? sz.width : sz.height)
            
            let spriteKitScene = SKScene(size: sceneSz)
            spriteKitScene.scaleMode = .aspectFit
            spriteKitScene.backgroundColor = UIColor.clear
            let ratio = sz.width/sz.height
            
            if self.height <= 0 {
                self.height = self.width / ratio
            }
            
            let videoSprite = SKVideoNode(avPlayer: p)
            videoSprite.size = sz
            
            if needRotate {
                videoSprite.zRotation = CGFloat.pi / 2
            }
            videoSprite.position = CGPoint(x: spriteKitScene.size.width / 2, y: spriteKitScene.size.height / 2)
            //videoSprite.play()
            videoSprite.yScale = -1
            
            spriteKitScene.addChild(videoSprite)
            if needRotate {
                spriteKitScene.zRotation = CGFloat.pi / 2
            }
            fore.diffuse.contents = spriteKitScene
            
            notificationObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: p.currentItem, queue: nil, using: { item in
                DispatchQueue.main.async {
                    self.player?.seek(to: CMTime.zero)
                    self.player?.play()
                }
            })
        } else {
            fore.diffuse.contents = _thumb
        }
        scn.materials = [fore, back, fore, back, back, back]
    }
    var width: CGFloat {
        get {
            return scn.width
        }
        set {
            scn.width = newValue
        }
    }
    var height: CGFloat {
        get {
            return scn.height
        }
        set {
            scn.height = newValue
        }
    }
    var transparency: CGFloat {
        get {
            return scn.firstMaterial!.transparency
        }
        set {
            scn.firstMaterial!.transparency = newValue
        }
    }
    
    public var length: CGFloat {
        get {
            return scn.length
        }
        set {
            scn.length = newValue
        }
    }
    
    public var player: AVPlayer? {
        get {
            return _player
        }
        set {
            if let o = self.notificationObserver {
                self.notificationObserver = nil
                NotificationCenter.default.removeObserver(o)
            }
            _player = newValue
            setMaterials()
        }
    }
    
    public var thumb: UIImage? {
        return _thumb
    }
}
