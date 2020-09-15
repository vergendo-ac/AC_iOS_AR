//
//  InteractivePanel.swift
//  myPlace
//
//  Created by Andrei Okoneshnikov on 19/08/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

protocol InteractivePanelDelegate : class {
    func interactivePanel(tapEnded: CGPoint)
}

class InteractivePanel: UIView {
    private weak var delegate: InteractivePanelDelegate?
    private var nodes: [StickerModels.Node] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    func initialize(delegate: InteractivePanelDelegate) {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:)))
        tapGR.delegate = self
        tapGR.cancelsTouchesInView = false
        addGestureRecognizer(tapGR)
        self.delegate = delegate
    }
    
    
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended, .cancelled:
            let point = sender.location(in: self)
            delegate?.interactivePanel(tapEnded: point)
        default: break
            
        }
    }
    
    func setNodes(_ nodes: [StickerModels.Node]) {
        self.nodes = nodes
        setNeedsDisplay()
    }
    
    func clear() {
        self.nodes = []
        setNeedsDisplay()
    }
    
    // MARK: Draw node
    
    private func drawNode(node: StickerModels.Node) {
        guard let points = node.points, points.count > 2 else {
            return
        }
        
        let path = UIBezierPath()

        for (index, point) in points.enumerated() {
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.addLine(to: points[0])
        path.close()
        path.lineWidth = 2.0
        
        UIColor.red.set()
        path.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        for node in nodes {
            drawNode(node: node)
        }
    }
}

extension InteractivePanel : UIGestureRecognizerDelegate {
    
}
