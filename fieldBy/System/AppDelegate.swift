//
//  AppDelegate.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/01.
//

import UIKit
import Firebase
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
                
        // Initialize Facebook SDK
        FBSDKCoreKit.ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
//        if let user = Auth.auth().currentUser {
//            //MARK: 유저 정보 불러오기
//            MyUserModel.shared.uuid = user.uid
//            toMain()
//        } else {
//            toAuth()
//        }

        toAuth()
//        uiTest()
        
        return true

    }
    
    func uiTest() {
        let vc = UIStoryboard(name: "UserInfo", bundle: nil).instantiateViewController(withIdentifier: "userinfoVC") as! UserInfoViewController
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    
    func toMain() {
        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
    }

    func toAuth() {
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "signinVC") as! SigninViewController
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }

}

