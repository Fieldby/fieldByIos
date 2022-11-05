//
//  DefaultViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/16.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import FirebaseAuth
import FirebaseDatabase
import Photos
import AVFoundation
import Lottie

class DefaultViewController: UIViewController {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        checkAppInfo()
        
        indicator.startAnimating()
        

    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        checkUserValid()
            .subscribe(onNext: { [unowned self] code in
                print(code)
                
                if code == 0 {
                    toMain()
                } else if code == 1 {
                    toAuth()
                } else if code == 2 {
                    presentAlert(message: "서버 문제입니다. 관리자에게 문의하세요. code 0000")
                }


            })
            .disposed(by: rx.disposeBag)

    }
    
    /*
     code
     0 : Success
     1 : unValid
     */
    
    //MARK: TODO - 고칠 것
    
    private func checkUserValid() -> Observable<Int> {
        Observable.create() { [unowned self] observable in
            if let uuid = Auth.auth().currentUser?.uid {
                AuthManager.shared.fetch(uuid: uuid)
                    .subscribe { [unowned self] in
                        
                        observable.onNext(0)
                    } onError: { err in
                        
                        observable.onNext(1)
                    }
                    .disposed(by: rx.disposeBag)

            } else {
                print("no Uid")
                observable.onNext(1)
            }
            return Disposables.create()
        }
    }

    func toMain() {
        
        CampaignManager.shared.fetch()
            .subscribe { [unowned self] in

                indicator.stopAnimating()
                let vc = MainTabBarController()
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)

            } onError: { [unowned self] error in
                indicator.stopAnimating()
                print(error)
                presentAlert(message: "서버 문제입니다. 관리자에게 문의하세요.")
            }
            .disposed(by: rx.disposeBag)

    }

    private func toAuth() {
        indicator.stopAnimating()

        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "signinVC") as! SigninViewController
        let nav = UINavigationController(rootViewController: vc)
        
        AuthManager.shared.defaultVC = self
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: false)
        
    }
    
    func uiTest() {
        let vc = UIStoryboard(name: "UserInfo", bundle: nil).instantiateViewController(withIdentifier: "finalinfoVC") as! FinalInfoViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: false)
    }
    
    func checkAppInfo() {
        var userCount = 0
        var igCount = 0
        var bestImageCount = 0
        
        Database.database().reference().child("users")
            .observeSingleEvent(of: .value) { dataSnapShot in
                for userData in dataSnapShot.children.allObjects as! [DataSnapshot] {
                    if userData.exists() {
                        userCount += 1
                        
                        if userData.childSnapshot(forPath: "igInfo").exists() {
                            igCount += 1
                        }
                        
                        if userData.childSnapshot(forPath: "bestImages").exists() {
                            bestImageCount += 1
                        }
                    }
                }
                
                Database.database().reference().child("appInfo").child("총유저수").setValue("\(userCount)명")
                Database.database().reference().child("appInfo").child("인스타연동계정수").setValue("\(igCount)명")
                Database.database().reference().child("appInfo").child("대표사진등록계정수").setValue("\(bestImageCount)명")
            }
    }
}
