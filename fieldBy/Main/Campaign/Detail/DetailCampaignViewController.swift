//
//  DetailCampaignViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/12.
//

import UIKit
import Kingfisher

class DetailCampaignViewController: UIViewController {

    static let storyId = "detailcampaignVC"
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var timeStickyContainer: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var isNewContainer: UIView!
    
    
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    var campaignModel: CampaignModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bind()
    }
    

    private func makeUI() {
        timeStickyContainer.layer.cornerRadius = 14.5
        isNewContainer.layer.cornerRadius = 14.5
        
        mainScrollView.contentInsetAdjustmentBehavior = .never
    }
    
    private func bind() {
        if let url = URL(string: campaignModel.url) {
            mainImageView.kf.setImage(with: url)
        }

        brandNameLabel.text = campaignModel.brandName
        
        isNewContainer.isHidden = !campaignModel.isNew
        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}
