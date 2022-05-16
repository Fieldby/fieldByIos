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
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "defaultVC")
        window?.rootViewController = vc
        window?.makeKeyAndVisible()

        
        return true

    }
    

    


}

