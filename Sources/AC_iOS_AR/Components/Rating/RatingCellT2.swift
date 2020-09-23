//
//  RatingCell.swift
//  myPlace
//
//  Created by Mac on 20/02/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import UIKit

class RatingCellT2: UICollectionViewCell {

    
    @IBOutlet weak var ratingCircleView: RatingCircleViewT2!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.insetsLayoutMarginsFromSafeArea = false
        
    }
    
    deinit {
        print("deinit RatingCell")
    }
    
    public func configure(with cellIndex: Float, totalRatingValue: Float, colorType: CategoryPin) {
        let divRemain = totalRatingValue / (cellIndex + 1)
        let remain = ((totalRatingValue - cellIndex) < 0.5) ? 0 : 0.5
        
        let circlePart = (divRemain < 1) ? remain : 1 //remain vs 0
        self.ratingCircleView.setAngles(with: Float(circlePart), index: Int(cellIndex))
        self.ratingCircleView.setType(color: colorType)
    }
    
}
