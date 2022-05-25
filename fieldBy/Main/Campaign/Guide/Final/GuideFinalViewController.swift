//
//  GuideFinalViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/19.
//

import UIKit

class GuideFinalViewController: CommonGuideViewController {
    
    static let storyId = "guidefinalVC"

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var viewMyCampaignsButton: UIButton!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    
    var size: String?
    var color: String?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        dismissButton.layer.cornerRadius = 13
        viewMyCampaignsButton.layer.cornerRadius = 13
        
        usernameLabel.text = "@\(AuthManager.shared.myUserModel.igModel!.username)님"
        
        dueDateLabel.text = "\(campaignModel.dueDate.month)월 \(campaignModel.dueDate.day)일 \(campaignModel.dueDate.hour)시 \(campaignModel.dueDate.minute)분"
        
        CampaignManager.shared.save(uuid: campaignModel.uuid, size: size, color: color)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func viewOthers(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
}
