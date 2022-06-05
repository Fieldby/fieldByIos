//
//  CampaignSelectedViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/06/05.
//

import UIKit
import FirebaseStorage

class CampaignSelectedViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var guideButton: UIButton!
    
    @IBOutlet weak var campaignImageView: UIImageView!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    
    
    @IBOutlet weak var container: UIView!
    
    var campaignModel: CampaignModel!
    
    static let storyId = "campaignselectedVC"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tabBar = tabBarController as! MainTabBarController
        
        tabBar.tabBar.isHidden = true
        tabBar.bottomView.isHidden = true
    
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let tabBar = tabBarController as! MainTabBarController
        
        tabBar.tabBar.isHidden = false
        tabBar.bottomView.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        campaignImageView.layer.cornerRadius = 4
        
        Storage.storage().reference().child(campaignModel.mainImageUrl)
            .downloadURL { [unowned self] url, error in
                if let url = url {
                    campaignImageView.kf.setImage(with: url)
                }
            }
        brandNameLabel.text = campaignModel.brandName
        itemNameLabel.text = campaignModel.itemModel.name
        
        guideButton.layer.cornerRadius = 13
        
        container.layer.cornerRadius = 13
        container.addGrayShadow()
        
        mainLabel.text = "축하합니다 @\(AuthManager.shared.myUserModel.igModel!.username)"
    }
    
    @IBAction func pop(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
