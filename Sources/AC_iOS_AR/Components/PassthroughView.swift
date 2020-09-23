//
//  PassthroughView.swift
//  myPlace
//
//  Created by Mac on 31/05/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import UIKit

class PassthroughView: UIView {
    
    var viewForHit: UIView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view: UIView = self
        if let hitView = viewForHit?.hitTest(point, with: event) {
            view = hitView
        } else if let hitView = super.hitTest(point, with: event){
            view = hitView
        } else if let hitView = super.subviews.compactMap({ $0.hitTest(point, with: event) }).first {
            view = hitView
        }
        return view == self ? nil : view
    }
    
}


