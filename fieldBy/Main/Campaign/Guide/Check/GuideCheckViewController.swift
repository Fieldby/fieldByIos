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

    @IBOutlet weak var acceptAllImage: UIImageView!
    @IBOutlet weak var acceptAllButton: UIButton!
    
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var marketingButton: UIButton!
    @IBOutlet weak var marketingImage: UIImageView!
    
    
    @IBOutlet weak var thirdPartyImage: UIImageView!
    @IBOutlet weak var thirdPartyButton: UIButton!
    
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
        
        nextButton.layer.cornerRadius = 13

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
        
        
        nextButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let vc = storyboard?.instantiateViewController(withIdentifier: GuideFinalViewController.storyId) as! GuideFinalViewController
                vc.campaignModel = campaignModel
                navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
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
    }

}
