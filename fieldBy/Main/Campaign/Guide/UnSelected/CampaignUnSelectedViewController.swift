//
//  CampaignUnSelectedViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/06/05.
//

import UIKit

class CampaignUnSelectedViewController: UIViewController {

    static let storyId = "campaignunselectedVC"
    
    @IBOutlet weak var popButton: UIButton!
    
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

        popButton.layer.cornerRadius = 13
        // Do any additional setup after loading the view.
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
