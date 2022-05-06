//
//  MainTabBarController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/04.
//

import UIKit
import SnapKit
import Then

class MainTabBarController: UITabBarController {

    private var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        bottomView = UIView().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 25
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.height.equalTo(25)
            $0.leading.equalTo(-2)
            $0.trailing.equalTo(2)
            $0.bottom.equalTo(tabBar.snp.top)
        }
        

        
        let campaignSB = UIStoryboard(name: "Campaign", bundle: nil)
        let campaignVC = campaignSB.instantiateViewController(withIdentifier: "campaignVC") as! CampaignViewController
        campaignVC.tabBarItem = UITabBarItem(title: "리스트",
                                            image: UIImage(named: "CampaignU"),
                                            selectedImage: UIImage(named: "CampaignS"))
        
        
        let progressSB = UIStoryboard(name: "Progress", bundle: nil)
        let progressVC = progressSB.instantiateViewController(withIdentifier: "progressVC") as! ProgressViewController
        progressVC.tabBarItem = UITabBarItem(title: "진행내역",
                                         image: UIImage(named: "ProgressU"),
                                         selectedImage: UIImage(named: "ProgressS"))
        
        
        let infoSB = UIStoryboard(name: "Info", bundle: nil)
        let infoVC = infoSB.instantiateViewController(withIdentifier: "infoVC") as! InfoViewController
        infoVC.tabBarItem = UITabBarItem(title: "내정보",
                                         image: UIImage(named: "InfoU"),
                                         selectedImage: UIImage(named: "InfoS"))
        view.backgroundColor = .white
        tabBar.backgroundColor = .white
        tabBar.tintColor = .main
        tabBar.unselectedItemTintColor = .black
        
        

        
        viewControllers = [
            UINavigationController(rootViewController: campaignVC),
            UINavigationController(rootViewController: progressVC),
            UINavigationController(rootViewController: infoVC)
        ]
    }
    


}
