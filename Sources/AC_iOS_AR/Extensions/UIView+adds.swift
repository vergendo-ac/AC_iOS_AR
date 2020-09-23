//
//  UIView+adds.swift
//  myPlace
//
//  Created by Mac on 01/03/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func activateConstraint(leading: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil,
                  trailing: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil,
                  top: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil,
                  bottom: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil,
                  centerX: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil,
                  centerY: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil,
                  width: CGFloat? = nil,
                  height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let leading = leading   { leadingAnchor.constraint(equalTo: leading).isActive = true }
        if let trailing = trailing { trailingAnchor.constraint(equalTo: trailing).isActive = true }
        if let top = top           { topAnchor.constraint(equalTo: top).isActive = true }
        if let bottom = bottom     { bottomAnchor.constraint(equalTo: bottom).isActive = true }
        if let centerX = centerX   { centerXAnchor.constraint(equalTo: centerX).isActive = true }
        if let centerY = centerY   { centerYAnchor.constraint(equalTo: centerY).isActive = true }
        if let width = width       { widthAnchor.constraint(equalToConstant: width).isActive = true }
        if let height = height     { heightAnchor.constraint(equalToConstant: height).isActive = true }
    }
    
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
    
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func xibSetup() {
        backgroundColor = UIColor.clear
        let view = loadNib()
        // use bounds not frame or it'll be offset
        view.frame = bounds
        // Adding custom subview on top of our view
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["childView": view]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["childView": view]))
    }
    
    func diagonal() -> CGFloat {
        return sqrt(pow(frame.size.width, 2.0) + pow(frame.size.height, 2.0))
    }
    
    func setHeight(_ h:CGFloat, animateTime:TimeInterval?=nil) {

        if let c = self.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal }) {
            c.constant = CGFloat(h)

            if let animateTime = animateTime {
                UIView.animate(withDuration: animateTime, animations:{
                    self.superview?.layoutIfNeeded()
                })
            }
            else {
                self.superview?.layoutIfNeeded()
            }
        }
    }
    
}
