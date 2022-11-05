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

    var bottomView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let igModel = AuthManager.shared.myUserModel.igModel {
            if let urlStr = igModel.profileUrl {
                let url = (try! URL(string: urlStr))!
                let data = try! Data(contentsOf: url)
                let image = UIImage(data: data)!.resizeImageTo(size: CGSize(width: 25, height: 25))!.roundedImage.withRenderingMode(.alwaysOriginal)

                
                tabBar.items![2].image = image
                tabBar.items![2].selectedImage = image
            }
        }
    }
    
    func hide() {
        tabBar.isHidden = true
        bottomView.isHidden = true
    }
    
    func show() {
        tabBar.isHidden = false
        bottomView.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userModel = AuthManager.shared.myUserModel!
        
        AuthManager.shared.mainTabBar = self

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
        
        let campaignNav = UINavigationController(rootViewController: campaignVC)
        let progressNav = UINavigationController(rootViewController: progressVC)
        let infoNav = UINavigationController(rootViewController: infoVC)
        
        campaignNav.interactivePopGestureRecognizer?.isEnabled = false
        progressNav.interactivePopGestureRecognizer?.isEnabled = false
        infoNav.interactivePopGestureRecognizer?.isEnabled = false

        
        viewControllers = [
            UINavigationController(rootViewController: campaignVC),
            UINavigationController(rootViewController: progressVC),
            UINavigationController(rootViewController: infoVC)
        ]
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    


}
