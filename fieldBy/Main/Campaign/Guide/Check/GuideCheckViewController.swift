//
//  GuideCheckViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/19.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class GuideCheckViewController: CommonGuideViewController {
    
    static let storyId = "guidecheckVC"
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var acceptAllImage: UIImageView!
    @IBOutlet weak var acceptAllButton: UIButton!
    @IBOutlet weak var acceptAllArrowButton: UIButton!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var marketingView: UIView!
    @IBOutlet weak var marketingButton: UIButton!
    @IBOutlet weak var marketingImage: UIImageView!
    @IBOutlet weak var guideButton: UIButton!
    
    
    @IBOutlet weak var nextButton: UIButton!
    
    private var acceptAll = false
    
    private var message = false
    private var marketing = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        
        nextButton.isEnabled = false
        nextButton.backgroundColor = .unabled
        
        nextButton.layer.cornerRadius = 13
        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)

        acceptAllButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                acceptAll ? cancelAgreeAll() : agreeAll()
            })
            .disposed(by: rx.disposeBag)
        
        
        messageButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                message ? messageDisagree() : messageAgree()
            })
            .disposed(by: rx.disposeBag)
        
        marketingButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                marketing ? marketingDisagree() : marketingAgree()
            })
            .disposed(by: rx.disposeBag)
        
        acceptAllArrowButton
            .rx.tap.subscribe(onNext: { [unowned self] in
                if messageView.isHidden {
                    UIView.animate(withDuration: 0.3) { [unowned self] in
                        acceptAllArrowButton.setImage(UIImage(named: "chevron.up"), for: .normal)
                        [messageView, marketingView]
                            .forEach { $0!.isHidden = false }
                    }
                } else {
                    UIView.animate(withDuration: 0.3) { [unowned self] in
                        acceptAllArrowButton.setImage(UIImage(named: "chevron.down"), for: .normal)
                        [messageView, marketingView]
                            .forEach { $0!.isHidden = true }
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        guideButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                indicator.isHidden = false
                indicator.startAnimating()
                
                CampaignManager.shared.guideImages(campaignModel: campaignModel)
                    .subscribe(onNext: { [unowned self] images in
                        let vc = storyboard?.instantiateViewController(withIdentifier: "guidecampaignVC") as! GuideCampaignViewController
                        vc.guideImages = images
                        vc.campaignModel = campaignModel
                        indicator.stopAnimating()
                        indicator.isHidden = true
                        navigationController?.pushViewController(vc, animated: true)
                    })
                    .disposed(by: rx.disposeBag)
                
            })
            .disposed(by: rx.disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                nextAction()
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func nextAction() {
        if campaignModel.itemModel.option == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: GuideFinalViewController.storyId) as! GuideFinalViewController
            vc.campaignModel = campaignModel
            
            PushManager.shared.commonPush(targetToken: AuthManager.shared.myUserModel.fcmToken!, notiType: .campaignApplied, campaignModel)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Size", bundle: nil).instantiateViewController(withIdentifier: "guidesizeVC") as! GuideSizeViewController
            vc.campaignModel = campaignModel
            navigationController?.pushViewController(vc, animated: true)
        }
        
        NotiManager.shared.sendCampaignApplied(campaignModel: campaignModel)
    }
    
    private func messageAgree() {
        message = true
        messageImage.image = UIImage(named: "authCheckSelected")
        
        if message, marketing {
            agreeAll()
        }
        
    }
    
    private func messageDisagree() {
        message = false
        messageImage.image = UIImage(named: "authCheckUnselected")
        if acceptAll {
            simpleCancel()
        }
    }

    private func marketingAgree() {
        marketing = true
        marketingImage.image = UIImage(named: "authCheckSelected")
        if message, marketing {
            agreeAll()
        }
    }
    
    private func marketingDisagree() {
        marketing = false
        marketingImage.image = UIImage(named: "authCheckUnselected")
        if acceptAll {
            simpleCancel()
        }
    }

    
    
    private func agreeAll() {
        acceptAll = true
        acceptAllImage.image = UIImage(named: "authCheckSelected")
        
        messageImage.image = UIImage(named: "authCheckSelected")
        message = true
        
        marketingImage.image = UIImage(named: "authCheckSelected")
        marketing = true

        
        UIView.animate(withDuration: 0.3) { [unowned self] in
            acceptAllArrowButton.setImage(UIImage(named: "chevron.down"), for: .normal)
            [messageView, marketingView]
                .forEach { $0!.isHidden = true }
        }

        nextButton.isEnabled = true
        nextButton.backgroundColor = .main
        
    }
    
    private func simpleCancel() {
        acceptAll = false
        acceptAllImage.image = UIImage(named: "authCheckUnselected")
    }
    
    private func cancelAgreeAll() {
        acceptAll = false
        acceptAllImage.image = UIImage(named: "authCheckUnselected")
        
        messageImage.image = UIImage(named: "authCheckUnselected")
        message = false
        
        marketingImage.image = UIImage(named: "authCheckUnselected")
        marketing = false

        
        UIView.animate(withDuration: 0.3) { [unowned self] in
            acceptAllArrowButton.setImage(UIImage(named: "chevron.up"), for: .normal)
            [messageView, marketingView]
                .forEach { $0!.isHidden = false }
        }
        
        nextButton.isEnabled = false
        nextButton.backgroundColor = .unabled
    }
    
    @IBAction func thirdParty(_ sender: Any) {
        openUrl(url: "https://hyuwo.notion.site/3-c548547717794ec9ae4c524821ecf1d4")
    }
    
}
