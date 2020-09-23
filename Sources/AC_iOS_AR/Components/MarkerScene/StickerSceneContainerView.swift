//
//  StickerSceneContainerView.swift
//  YaPlace
//
//  Created by Andrei Okoneshnikov on 05.03.2020.
//  Copyright © 2020 SKZ. All rights reserved.
//

import UIKit

class StickerSceneContainerView: UIView {
    
    private var dashLineColor = UIColor.clear
    private var dashPoints: (start: CGPoint, end: CGPoint)?
    
    func setDashColor(color: UIColor) {
        dashLineColor = color
    }
    
    func setDashPoints(startPoint: CGPoint, endPoint: CGPoint) {
        dashPoints = (startPoint, endPoint)
        setNeedsDisplay()
    }
    
    func removeDashedPoints() {
        dashPoints = nil
        setNeedsDisplay()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        guard let points = dashPoints else {
            return
        }
        self.backgroundColor = UIColor.clear
        // Drawing code
        let path = UIBezierPath()
        let dottArray:[CGFloat] = [5]
        
        path.move(to: points.start)
        path.addLine(to: points.end)
        path.lineWidth = 2.0
        path.lineCapStyle = .round
        //path.setLineDash(dottArray, count: 5, phase: 0)
        
        dashLineColor.set()
        path.stroke()
    }
}
