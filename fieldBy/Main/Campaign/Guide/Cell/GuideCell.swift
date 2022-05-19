//
//  GuideCell.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/19.
//

import Foundation
import UIKit

class GuideCell: UICollectionViewCell {
    static let reuseId = "guideCell"
    
    @IBOutlet weak var guideImageView: UIImageView!
    @IBOutlet weak var guideLabel: UILabel!
    
    override func awakeFromNib() {
        guideImageView.layer.cornerRadius = 7
    }
    
}
