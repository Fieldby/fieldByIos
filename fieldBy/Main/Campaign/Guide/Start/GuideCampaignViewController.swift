//
//  GuideCampaignViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/18.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class GuideCampaignViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    /*
     Top View
     */
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var infoContainer: UIView!
    
    @IBOutlet weak var leastFeedLabel: UILabel!
    @IBOutlet weak var maintainLabel: UILabel!
    
    /*
     Middle View
     */
    
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    /*
     Bottom View
     */
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var ftcLabel: UILabel!
    @IBOutlet weak var ftcButton: UIButton!
    @IBOutlet weak var ftcView: UIView!
    
    @IBOutlet weak var requiredLabel: UILabel!
    @IBOutlet weak var requiredButton: UIButton!
    @IBOutlet weak var requiredView: UIView!
    
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var optionView: UIView!
    
    @IBOutlet weak var brandInstagramLabel: UILabel!
    @IBOutlet weak var brandInstagramButton: UIButton!
    @IBOutlet weak var brandView: UIView!
    
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var applyButton: UIButton!
    
    
    

    @IBOutlet var viewModel: GuideCampaignViewModel!
    
    var campaignModel: CampaignModel!
    var guideImages: [UIImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setDelegate()
        makeUI()
        bind()
    }
    
    private func setDelegate() {
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    private func makeUI() {
        scrollView.contentInsetAdjustmentBehavior = .never
        infoContainer.addGrayShadow()
        topView.addGrayShadow()
        
        infoContainer.layer.cornerRadius = 21
        middleView.addGrayShadow()
        
        bottomView.addGrayShadow()
        
        [ftcView, requiredView, optionView, brandView]
            .forEach { $0!.layer.cornerRadius = 13 }
        [ftcButton, requiredButton, optionButton, brandInstagramButton]
            .forEach {
                $0!.layer.cornerRadius = 6
                $0!.addGrayShadow()
            }
        
        applyButton.layer.cornerRadius = 13
        
        buttonView.layer.cornerRadius = 21
        buttonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        buttonView.layer.borderColor = UIColor.fieldByGray.cgColor
        buttonView.layer.borderWidth = 1
        
    }
    

    private func bind() {
        
        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        leastFeedLabel.text = "\(campaignModel.leastFeed)회"
        maintainLabel.text = "\(campaignModel.maintain)일"
        
        
        Observable.just(guideImages)
            .bind(to: collectionView.rx.items(cellIdentifier: GuideCell.reuseId, cellType: GuideCell.self)) { [unowned self] idx, image, cell in
                
                cell.guideImageView.image = image
                cell.guideLabel.text = campaignModel.guides[idx].description
                
            }
            .disposed(by: rx.disposeBag)
        
        ftcLabel.text = campaignModel.hashTagModel.ftc
        requiredLabel.text = campaignModel.hashTagModel.required
        optionLabel.text = campaignModel.hashTagModel.option
        brandInstagramLabel.text = "@\(campaignModel.brandInstagram)"
        
        applyButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                viewModel.pushCautionVC()
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.pushCautionVC = { [unowned self] in
            let vc = storyboard?.instantiateViewController(withIdentifier: GuideCautionViewController.storyId) as! GuideCautionViewController
            vc.campaignModel = campaignModel
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    

}

extension GuideCampaignViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.frame.width-11)/2, height: (collectionView.frame.height-11)/2)
        
    }
}
