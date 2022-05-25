//
//  ProgressMainCell.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/20.
//

import UIKit
import FirebaseStorage

class ProgressMainCell: UITableViewCell {
    static let reuseId = "progressmainCell"
    
    @IBOutlet weak var guideButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var appliedLabel: UILabel!
    
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var deliveryView: UIView!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var deliveryBar: UIView!
    @IBOutlet weak var deliveryCircle: UIImageView!
    
    
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var uploadBar: UIView!
    @IBOutlet weak var uploadCircle: UIImageView!
    
    @IBOutlet weak var maintainView: UIView!
    @IBOutlet weak var maintainLabel: UILabel!
    @IBOutlet weak var maintainBar: UIView!
    @IBOutlet weak var maintainCircle: UIImageView!
    
    @IBOutlet weak var doneView: UIView!
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var doneBar: UIView!
    @IBOutlet weak var doneCircle: UIImageView!
    
    @IBOutlet weak var uploadButtonContainer: UIView!
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var dateContentLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        itemImageView.layer.cornerRadius = 7
        
        deliveryView.isHidden = true
        deliveryView.layer.cornerRadius = 8.5
        uploadView.isHidden = true
        uploadView.layer.cornerRadius = 8.5
        maintainView.isHidden = true
        maintainView.layer.cornerRadius = 8.5
        doneView.isHidden = true
        doneView.layer.cornerRadius = 8.5
        
        uploadButton.layer.cornerRadius = 10
        uploadButtonContainer.isHidden = true
        appliedLabel.isHidden = true
    }
    
    func bind(campaignModel: CampaignModel, status: CampaignStatus) {
        
        mainView.addGrayShadow(color: .black, opacity: 1, radius: 3)
        Storage.storage().reference().child(campaignModel.mainImageUrl)
            .downloadURL { [unowned self] url, error in
                if let url = url {
                    itemImageView.kf.setImage(with: url)
                }
            }
        
        brandNameLabel.text = campaignModel.brandName
        itemNameLabel.text = campaignModel.itemModel.name
        
        deliveryLabel.text = "\(campaignModel.itemDate.month).\(campaignModel.itemDate.day)"
        uploadLabel.text = "\(campaignModel.uploadDate.month).\(campaignModel.uploadDate.day)"
        
        switch status {
        case .unOpened:
            break
        case .applied:
            setApplied()
        case .delivering:
            setDelivery(campaignModel)
        case .uploading:
            setUpload(campaignModel)
            
        case .maintaining:
            setMaintain()
            
        case .done:
            setDone()
            
        }
        
    }
    
    private func setApplied() {
        progressView.isHidden = true
        appliedLabel.isHidden = false
        guideButton.isHidden = true
    }
    
    private func setDelivery(_ campaignModel: CampaignModel) {
        progressView.isHidden = false
        deliveryView.isHidden = false
        
        dateContentLabel.text = "배송기간(~\(campaignModel.itemDate.month).\(campaignModel.itemDate.day))입니다!"
        desLabel.text = "곧 제품이 배송됩니다"
        
    }
    
    private func setUpload(_ campaignModel: CampaignModel) {
        deliveryCircle.tintColor = .main
        deliveryBar.backgroundColor = .main
        progressView.isHidden = false
        uploadView.isHidden = false
        
        uploadButtonContainer.isHidden = false
        
        
        dateContentLabel.text = "업로드기간(~\(campaignModel.uploadDate.month).\(campaignModel.uploadDate.day))입니다!"
        desLabel.text = "가이드에 맞게 컨텐츠를 업로드 해주세요 :)"
        
        
        uploadButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func setMaintain() {
        deliveryCircle.tintColor = .main
        deliveryBar.backgroundColor = .main
        uploadCircle.tintColor = .main
        uploadBar.backgroundColor = .main
        progressView.isHidden = false
        maintainView.isHidden = false
    }
    
    private func setDone() {
        progressView.isHidden = true
        guideButton.isHidden = true
        appliedLabel.isHidden = false
        appliedLabel.text = "캠페인 완료"
        appliedLabel.textColor = UIColor(red: 48, green: 48, blue: 48)
    }
}
