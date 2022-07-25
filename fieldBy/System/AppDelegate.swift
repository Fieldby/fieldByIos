//
//  AppDelegate.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/01.
//

import UIKit
import Firebase
import FBSDKCoreKit
import ChannelIOFront
//import FirebaseCore
//import FirebaseAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()	

        // Initialize Facebook SDK
        FBSDKCoreKit.ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        Messaging.messaging().delegate = self
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "defaultVC")
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        ChannelIO.initialize(application)

        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: { didAllow,Error in
                if didAllow {
                    print("Push: 권한 허용")
                } else {
                    print("Push: 권한 거부")
                }
            })
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        UIApplication.shared.registerForRemoteNotifications()


        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
              AuthManager.shared.fcmToken = token
              Messaging.messaging().subscribe(toTopic: "fieldBy") { error in
                print("Subscribed to weather topic")
              }
              
          }
        }

        
        return true

    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        ChannelIO.initPushToken(deviceToken: deviceToken)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
        let userInfo = notification.request.content.userInfo
        
        print(userInfo)
        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound]])

    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }  
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        if ChannelIO.isChannelPushNotification(userInfo) {
            ChannelIO.receivePushNotification(userInfo)
            ChannelIO.storePushNotification(userInfo)
        }
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            
//            let _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
//                if let _ = self.window?.visibleViewController as? NewHomeViewController {
//                    self.handleUserInfo(userInfo)
//                    timer.invalidate()
//                }
//            }
        } else {
//            handleUserInfo(userInfo)

        }
        completionHandler()

    }

}

