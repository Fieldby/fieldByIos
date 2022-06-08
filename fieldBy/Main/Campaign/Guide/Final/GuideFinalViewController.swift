//
//  GuideFinalViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/19.
//

import UIKit
import FirebaseStorage

class GuideFinalViewController: CommonGuideViewController {
    
    static let storyId = "guidefinalVC"

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var viewMyCampaignsButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    var size: String?
    var color: String?
    
    var isAppling = true
    var campaignImage: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        if let token = AuthManager.shared.myUserModel.igModel?.token {
            InstagramManager.shared.igLogin(token: token) {
                
            }
        }

        
        dismissButton.layer.cornerRadius = 13
        viewMyCampaignsButton.layer.cornerRadius = 13
        
        usernameLabel.text = "@\(AuthManager.shared.myUserModel.igModel!.username)님"
        
        dueDateLabel.text = "\(campaignModel.selectionDate.month)월 \(campaignModel.selectionDate.day)일"
        
        if isAppling {
            CampaignManager.shared.save(uuid: campaignModel.uuid, size: size, color: color)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            backButton.isHidden = true
        } else {
            backButton.isHidden = false
        }
        

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
        presentDetailVC(campaignModel: campaignModel, image: campaignImage)
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
