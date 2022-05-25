//
//  InfoViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/04.
//

import UIKit
import FBSDKLoginKit
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Kingfisher

class InfoViewController: UIViewController {    
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var campaignCounts: UILabel!
    @IBOutlet weak var totalRewardsLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bind()
    }
    
    private func makeUI() {
        topView.layer.cornerRadius = 27
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        topView.addGrayShadow(color: .lightGray, opacity: 0.3, radius: 3)
        
        profileImageView.layer.cornerRadius = 35
    }
    
    private func bind() {
        
        if let igModel = AuthManager.shared.myUserModel.igModel {
            if let url = igModel.profileUrl {
                
                let url = try! URL(string: url)
                profileImageView.kf.setImage(with: url)
            }
            
            usernameLabel.text = "@\(igModel.username)"
            followersCountLabel.text = "팔로워 \(igModel.followers)"
            
            campaignCounts.text = "\(AuthManager.shared.myUserModel.campaigns.count)"
            
            
            
            
        }
        

        
        
        
        
    }
    
    @IBAction func test(_ sender: Any) {
        let manager = LoginManager()
        manager.logIn(permissions: ["public_profile", "instagram_basic", "pages_show_list"], from: self) { result, error in
            if let error = error {
                print("Process error: \(error)")
                return
            }
            guard let result = result else {
                print("No Result")
                return
            }
            if result.isCancelled {
                print("Login Cancelled")
                return
            }

            InstagramManager.shared.igLogin(token: result.token!.tokenString)

        }
    }
}
