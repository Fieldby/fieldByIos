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
    
    var buttonHandler: (() -> Void)!
    
    var guidButtonHandler: (() -> Void)!
    
    
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
    
    func bind(campaignModel: CampaignModel, userModel: UserCampaignModel) {
                
        if userModel.imageArray.count != 0 {
            uploadButton.setTitle("다시 업로드 하기", for: .normal)
            
        } else {
            uploadButton.setTitle("업로드 하기", for: .normal)
        }
        
        
        mainView.addGrayShadow(color: .black, opacity: 1, radius: 3)
        
        campaignModel.getMainImage()
            .subscribe(onSuccess: { [unowned self] image in
                itemImageView.image = image
            })
            .disposed(by: rx.disposeBag)

        brandNameLabel.text = campaignModel.brandName
        itemNameLabel.text = campaignModel.itemModel.name
        
        deliveryLabel.text = "~\(campaignModel.itemDate.month).\(campaignModel.itemDate.day)"
        uploadLabel.text = "~\(campaignModel.uploadDate.month).\(campaignModel.uploadDate.day)"
        
        maintainLabel.text = "\(dotDate(str: campaignModel.uploadDate))~\(dotDate(str: campaignModel.getFinishDate()))"
        
        switch campaignModel.status {
        case .unOpened:
            break
        case .applied:
            setApplied()
        case .delivering:
            setDelivery(campaignModel)
        case .uploading:
            setUpload(campaignModel, userModel)
            
        case .maintaining:
            setMaintain(campaignModel)
            
        case .done:
            setDone()
            
        }
        
    }
    
    private func setApplied() {
        progressView.isHidden = true
        appliedLabel.isHidden = false
        appliedLabel.text = "제안 완료"
        guideButton.isHidden = true
        uploadButtonContainer.isHidden = true
    }
    
    private func setDelivery(_ campaignModel: CampaignModel) {
        
        progressView.isHidden = false
        deliveryView.isHidden = false
        uploadButtonContainer.isHidden = true
        guideButton.isHidden = false
        appliedLabel.isHidden = true
        guideButton.setTitle("송장번호 확인하기>", for: .normal)
        dateContentLabel.text = "예상 배송기간(~\(campaignModel.itemDate.month).\(campaignModel.itemDate.day))입니다!"
        desLabel.text = "곧 제품이 배송됩니다"
        
    }
    
    private func setUpload(_ campaignModel: CampaignModel, _ userModel: UserCampaignModel) {
        deliveryCircle.tintColor = .main
        deliveryBar.backgroundColor = .main
        progressView.isHidden = false
        uploadView.isHidden = false
        guideButton.setTitle("가이드 확인하기>", for: .normal)
        uploadButtonContainer.isHidden = false
        
        if userModel.imageArray.count != 0 {
            dateContentLabel.text = "업로드를 완료했습니다!"
            desLabel.text = "가이드에 맞게 업로드하였는지 다시 한 번 확인해주세요."
        } else {
            dateContentLabel.text = "업로드기간(~\(campaignModel.uploadDate.month).\(campaignModel.uploadDate.day))입니다!"
            desLabel.text = "가이드에 맞게 컨텐츠를 업로드 해주세요 :)"
        }
        
    }
    @IBAction func guideTap(_ sender: Any) {
        guidButtonHandler()
    }
    
    @IBAction func upload(_ sender: Any) {
        buttonHandler()
    }
    
    private func setMaintain(_ model: CampaignModel) {
        deliveryCircle.tintColor = .main
        deliveryBar.backgroundColor = .main
        uploadCircle.tintColor = .main
        uploadBar.backgroundColor = .main
        progressView.isHidden = false
        maintainView.isHidden = false
        uploadButtonContainer.isHidden = true
        
        dateContentLabel.text = "업로드 유지기간(\(dotDate(str: model.uploadDate))~\(dotDate(str: model.getFinishDate()))) 입니다!"
        desLabel.text = "업로드 한 콘텐츠를 약속한 기간만큼 유지해주세요"
        
    }
    
    private func setDone() {
        progressView.isHidden = true
        guideButton.isHidden = true
        uploadButtonContainer.isHidden = true
        appliedLabel.isHidden = false
        appliedLabel.text = "캠페인 완료"
        appliedLabel.textColor = UIColor(red: 48, green: 48, blue: 48)
    }
    
    private func dotDate(str: String) -> String {
        return "\(str.month).\(str.day)"
    }
}
