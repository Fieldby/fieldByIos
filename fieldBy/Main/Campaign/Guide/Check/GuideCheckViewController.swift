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
    
    @IBOutlet weak var acceptAllImage: UIImageView!
    @IBOutlet weak var acceptAllButton: UIButton!
    @IBOutlet weak var acceptAllArrowButton: UIButton!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var marketingView: UIView!
    @IBOutlet weak var marketingButton: UIButton!
    @IBOutlet weak var marketingImage: UIImageView!
    
    
    @IBOutlet weak var thirdPartyView: UIView!
    @IBOutlet weak var thirdPartyImage: UIImageView!
    @IBOutlet weak var thirdPartyButton: UIButton!
    
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var privacyImage: UIImageView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    private var acceptAll = false
    
    private var message = false
    private var marketing = false
    private var thirdParty = false
    private var privacy = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        thirdPartyButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                thirdParty ? thirdPartyDisagree() : thirdPartyAgree()
            })
            .disposed(by: rx.disposeBag)
        
        privacyButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                privacy ? privacyDisagree() : privacyAgree()
            })
            .disposed(by: rx.disposeBag)
        
        acceptAllArrowButton
            .rx.tap.subscribe(onNext: { [unowned self] in
                if messageView.isHidden {
                    UIView.animate(withDuration: 0.3) { [unowned self] in
                        acceptAllArrowButton.setImage(UIImage(named: "chevron.up"), for: .normal)
                        [messageView, marketingView, thirdPartyView, privacyView]
                            .forEach { $0!.isHidden = false }
                    }
                } else {
                    UIView.animate(withDuration: 0.3) { [unowned self] in
                        acceptAllArrowButton.setImage(UIImage(named: "chevron.down"), for: .normal)
                        [messageView, marketingView, thirdPartyView, privacyView]
                            .forEach { $0!.isHidden = true }
                    }
                }
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
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Size", bundle: nil).instantiateViewController(withIdentifier: "guidesizeVC") as! GuideSizeViewController
            vc.campaignModel = campaignModel
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func messageAgree() {
        message = true
        messageImage.image = UIImage(named: "authCheckSelected")
        
        if message, marketing, thirdParty, privacy {
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
        if message, marketing, thirdParty, privacy {
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
    
    private func thirdPartyAgree() {
        thirdParty = true
        thirdPartyImage.image = UIImage(named: "authCheckSelected")
        if message, marketing, thirdParty, privacy {
            agreeAll()
        }
    }
    
    private func thirdPartyDisagree() {
        thirdParty = false
        thirdPartyImage.image = UIImage(named: "authCheckUnselected")
        if acceptAll {
            simpleCancel()
        }
    }
    
    private func privacyAgree() {
        privacy = true
        privacyImage.image = UIImage(named: "authCheckSelected")
        if message, marketing, thirdParty, privacy {
            agreeAll()
        }
    }
    
    private func privacyDisagree() {
        privacy = false
        privacyImage.image = UIImage(named: "authCheckUnselected")
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
        
        privacyImage.image = UIImage(named: "authCheckSelected")
        privacy = true
        
        thirdPartyImage.image = UIImage(named: "authCheckSelected")
        thirdParty = true
        
        UIView.animate(withDuration: 0.3) { [unowned self] in
            acceptAllArrowButton.setImage(UIImage(named: "chevron.down"), for: .normal)
            [messageView, marketingView, thirdPartyView, privacyView]
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
        
        privacyImage.image = UIImage(named: "authCheckUnselected")
        privacy = false
        
        thirdPartyImage.image = UIImage(named: "authCheckUnselected")
        thirdParty = false
        
        UIView.animate(withDuration: 0.3) { [unowned self] in
            acceptAllArrowButton.setImage(UIImage(named: "chevron.up"), for: .normal)
            [messageView, marketingView, thirdPartyView, privacyView]
                .forEach { $0!.isHidden = false }
        }
        
        nextButton.isEnabled = false
        nextButton.backgroundColor = .unabled
    }

}
