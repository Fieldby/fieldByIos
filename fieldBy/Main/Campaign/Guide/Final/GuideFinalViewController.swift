//
//  GuideFinalViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/19.
//

import UIKit
import FirebaseStorage
import RxSwift

class GuideFinalViewController: CommonGuideViewController {
    
    static let storyId = "guidefinalVC"

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var viewMyCampaignsButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    var option: String?
    
    var isAppling = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        if let token = AuthManager.shared.myUserModel.igModel?.token {
            InstagramManager.shared.igLogin(viewController: self, token: token) {
                
            }
        }

        
        dismissButton.layer.cornerRadius = 13
        viewMyCampaignsButton.layer.cornerRadius = 13
        
        usernameLabel.text = "@\(AuthManager.shared.myUserModel.igModel!.username)님"
        
        dueDateLabel.text = "\(campaignModel.selectionDate.month)월 \(campaignModel.selectionDate.day)일"
        
        if isAppling {
            CampaignManager.shared.save(campaignModel: campaignModel, option: option)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            backButton.isHidden = true
        } else {
            backButton.isHidden = false
        }
        
        viewMyCampaignsButton
            .rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .bind(onNext: { [unowned self] _ in
                campaignModel.getMainImage()
                    .subscribe { [unowned self] image in
                        presentDetailVC(campaignModel: campaignModel, image: image)
                    } onError: { err in
                        print(err)
                    }
                    .disposed(by: rx.disposeBag)

            })
            .disposed(by: rx.disposeBag)
            

    }
    
    @IBAction func dismiss(_ sender: Any) {
        if self.tabBarController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true) { [unowned self] in
                AuthManager.shared.mainTabBar.selectedIndex = 0
            }
        }
    }
    
    @IBAction func viewDetail(_ sender: Any) {

        
    }
    
    @IBAction func pop(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    private func presentDetailVC(campaignModel: CampaignModel, image: UIImage) {
        let vc = UIStoryboard(name: "Campaign", bundle: nil).instantiateViewController(withIdentifier: DetailCampaignViewController.storyId) as! DetailCampaignViewController
        vc.campaignModel = campaignModel
        vc.mainImage = image
        navigationController?.pushViewController(vc, animated: true)

    }
}
