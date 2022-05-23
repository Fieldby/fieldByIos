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

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let facebookLoginButton = UIButton(type: .custom)
        facebookLoginButton.backgroundColor = .blue
        facebookLoginButton.setTitle("Facebook Login", for: .normal)
        facebookLoginButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40)
        facebookLoginButton.center = view.center
        view.addSubview(facebookLoginButton)
        
        facebookLoginButton.addTarget(self, action: #selector(clickFacebookLogin), for: .touchUpInside)

    }
    
    
    @IBAction
    func clickFacebookLogin() {
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

            AuthManager.shared.fbToken = result.token!.tokenString
//            print("token: \(result.token?.tokenString)")
//            print("user: \(result.grantedPermissions)")
//
                




            
    
            // result properties
            //  - token : 액세스 토큰
            //  - isCancelled : 사용자가 로그인을 취소했는지 여부
            //  - grantedPermissions : 부여 된 권한 집합
            //  - declinedPermissions : 거부 된 권한 집합
        }
        
        
        
    }
    


    @IBAction func click(_ sender: Any) {

    }
    
}
