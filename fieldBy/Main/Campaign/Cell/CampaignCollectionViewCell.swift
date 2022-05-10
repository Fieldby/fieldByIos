//
//  CampaignCollectionViewCell.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/08.
//

import UIKit
import SnapKit


class CampaignCollectionViewCell: UICollectionViewCell {
    static let reuseId = "campaignCell"
    
    @IBOutlet weak var mainImage: UIImageView!
    
    func makeImageSmall() {
        mainImage.snp.makeConstraints {
            $0.height.equalToSuperview().offset(-80)
            $0.width.equalToSuperview()
        }
    }
}
