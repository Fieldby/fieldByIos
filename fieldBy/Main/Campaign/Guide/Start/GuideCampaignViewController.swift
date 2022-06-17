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

class GuideCampaignViewController: CommonGuideViewController {

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
    
    @IBOutlet weak var infoLabel: UILabel!
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
    
    @IBOutlet weak var snackBar: UIView!
    
    

    @IBOutlet var viewModel: GuideCampaignViewModel!
    
    var guideImages: [UIImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true

        setDelegate()
        makeUI()
        bind()
    }
    
    private func setDelegate() {
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    private func makeUI() {
        snackBar.layer.cornerRadius = 13
        snackBar.alpha = 0
        
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
        
        if campaignModel.brandUuid == "aC5LC34JqYeWE7UaD7iITrVdVXe2" {
            infoLabel.isHidden = false
        } else {
            infoLabel.isHidden = true
        }
        
    }
    

    private func bind() {
        
        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if navigationController?.children.count == 1 {
                    self.dismiss(animated: true)
                } else {
                    navigationController?.popViewController(animated: true)
                }
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
        
        ftcButton.rx.tap
            .bind(onNext: { [unowned self] in
                animateSnackBar()
                UIPasteboard.general.string = ftcLabel.text
            })
            .disposed(by: rx.disposeBag)
        
        requiredButton.rx.tap
            .bind(onNext: { [unowned self] in
                animateSnackBar()
                UIPasteboard.general.string = requiredLabel.text
            })
            .disposed(by: rx.disposeBag)
        
        optionButton.rx.tap
            .bind(onNext: { [unowned self] in
                animateSnackBar()
                UIPasteboard.general.string = optionLabel.text
            })
            .disposed(by: rx.disposeBag)
        
        brandInstagramButton.rx.tap
            .bind(onNext: { [unowned self] in
                animateSnackBar()
                UIPasteboard.general.string = brandInstagramLabel.text
            })
            .disposed(by: rx.disposeBag)
        
        
        
    }
    
    private func animateSnackBar() {
        UIView.animate(withDuration: 0.5) { [unowned self] in
            snackBar.alpha = 1
            
            UIView.animate(withDuration: 0.5, delay: 2) { [unowned self] in
                snackBar.alpha = 0
            }
        }
    }
    
    @IBAction func kakaoChannel(_ sender: Any) {
        openUrl(url: "http://pf.kakao.com/_xdxeQzb")
    }
    

}

extension GuideCampaignViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.frame.width-11)/2, height: (collectionView.frame.height-11)/2)
        
    }
}
