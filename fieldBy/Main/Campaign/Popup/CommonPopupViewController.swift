//
//  CommonPopupViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/24.
//

import UIKit

class CommonPopupViewController: UIViewController {
    
    static let storyId = "popupVC"
    
    var content: String!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    var topVC: UIViewController!
    var campaignModel: CampaignModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentLabel.text = content
        containerView.layer.cornerRadius = 13
        
    }

    @IBAction func click(_ sender: Any) {
        if content == "마감되었습니다" {
            self.dismiss(animated: true)
        } else if content.count > 30 {
            self.dismiss(animated: true)
        } else {
            CampaignManager.shared.cancel(campaignModel: campaignModel)
                .subscribe {
                    self.dismiss(animated: true) {
                        self.topVC.dismiss(animated: true)
                    }
                } onError: { err in
                    print(err)
                    self.dismiss(animated: true) {
                        self.topVC.dismiss(animated: true)
                    }
                }
                .disposed(by: rx.disposeBag)

        }
        
    }
    
}
