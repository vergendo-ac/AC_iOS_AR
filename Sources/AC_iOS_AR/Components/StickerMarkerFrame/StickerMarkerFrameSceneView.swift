//
//  StickerMarkerFrameSceneView.swift
//  myPlace
//
//  Created by Mac on 28/05/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import UIKit

//TODO - move to sticker frame view

@IBDesignable
class StickerMarkerFrameSceneView: UIView {
    
    //MARK: Outlets
    @IBOutlet var view: UIView!
    @IBOutlet weak var frameImageView: UIImageView!
    
    //MARK: vars
    var index: Int = -1
    
    //MARK: constants
    let red: CGFloat = 1.0
    let green: CGFloat = 0.0
    let blue: CGFloat = 0.0
    let brushWidth: CGFloat = 2.0
    let opacity: CGFloat = 1.0


    //MARK: designable
    /*
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    */
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    //MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(index: Int, stickerDistantFramePoints: PointModels.DistantFramePoints, stickerMarkerFrameViewCompletion: @escaping (Int) -> Swift.Void) {
        let minX = stickerDistantFramePoints.1.reduce(into: CGFloat.greatestFiniteMagnitude, { $0 = min($0, $1.x) })
        let minY = stickerDistantFramePoints.1.reduce(into: CGFloat.greatestFiniteMagnitude, { $0 = min($0, $1.y) })
        let maxX = stickerDistantFramePoints.1.reduce(into: CGFloat.leastNormalMagnitude, { $0 = max($0, $1.x) })
        let maxY = stickerDistantFramePoints.1.reduce(into: CGFloat.leastNormalMagnitude, { $0 = max($0, $1.y) })
        
        self.init(frame: CGRect(
            x: minX,
            y: minY,
            width:  maxX - minX,
            height: maxY - minY
        ))
        
        self.index = index
        self.viewSetup(stickerDistantFramePoints.1)
    }
    
    deinit {
        print("deinit StickerMarkerSceneView")
    }
    
    //MARK: life cycle
    
    private func viewSetup(_ frame: [CGPoint]) {
        self.xibSetup()
        self.showStickerFrame(frame) //for moveTo draw need one more point
        self.setupBorders()
        self.tag = Tags.value.StickerMarkerFrameView.rawValue
    }
    
    private func setupBorders() {
        /*let yourColor : UIColor = .blue
        self.layer.masksToBounds = true
        self.layer.borderColor = yourColor.cgColor
        self.layer.borderWidth = 2.0*/
        
        self.isUserInteractionEnabled = false
        self.frameImageView.isUserInteractionEnabled = false
    }

    private func showStickerFrame(_ frame: [CGPoint]) {
        
        guard frame.count > 3 else { return }
        
        let bounds = CGRect(origin: .zero, size: self.frame.size)
        
        let normalFrame = Geometry
            .graham(cgpoints: frame)
            .map { CGPoint(x: $0.x - self.frame.origin.x, y: $0.y - self.frame.origin.y) }
        
        UIGraphicsBeginImageContext(bounds.size)
        self.frameImageView.image?.draw(in: bounds)
        UIGraphicsGetCurrentContext()?.clear(bounds)
        
        UIGraphicsGetCurrentContext()?.move(to: normalFrame.first!)
        for value in normalFrame.reversed() {
            UIGraphicsGetCurrentContext()?.addLine(to: value)
        }
        
        UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
        UIGraphicsGetCurrentContext()?.setLineWidth(self.brushWidth)
        UIGraphicsGetCurrentContext()?.setStrokeColor(red: red, green: green, blue: blue, alpha: opacity)
        UIGraphicsGetCurrentContext()?.strokePath()
        
        self.frameImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    public func move(stickerFramePoints: [CGPoint]) {
        
        guard stickerFramePoints.count > 3 else { return }
        
        let minX = stickerFramePoints.reduce(into: CGFloat.greatestFiniteMagnitude, { $0 = min($0, $1.x) })
        let minY = stickerFramePoints.reduce(into: CGFloat.greatestFiniteMagnitude, { $0 = min($0, $1.y) })
        let maxX = stickerFramePoints.reduce(into: CGFloat.leastNormalMagnitude, { $0 = max($0, $1.x) })
        let maxY = stickerFramePoints.reduce(into: CGFloat.leastNormalMagnitude, { $0 = max($0, $1.y) })
        
        DispatchQueue.main.async {
            self.frame = CGRect(
                x: minX,
                y: minY,
                width:  maxX - minX,
                height: maxY - minY
            )
            self.showStickerFrame(stickerFramePoints)
        }
        
    }

}
