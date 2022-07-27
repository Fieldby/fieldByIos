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
    
    private let animationDone = BehaviorRelay<Bool>(value: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        print("defaultView")
        let animationView = AnimationView()
        animationView.animation = Animation.named("logoAnimation")
        animationView.frame = view.bounds
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play { [unowned self] finished in
            if finished {
                animationDone.accept(true)
            }
        }
        
        view.addSubview(animationView)
//        checkAppInfo()

    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Observable.combineLatest(checkUserValid(), animationDone)
            .subscribe(onNext: { [unowned self] code, isDone in
                if isDone {
                    if code == 0 {
                        toMain()
                    } else if code == 1 {
                        toAuth()
                    } else if code == 2 {
                        presentAlert(message: "서버 문제입니다. 관계자에게 문의하세요.")
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
//        checkUserValid()
//            .subscribe(onNext: { [unowned self] code in
//                print(code)
//
//                if code == 0 {
//                    toMain()
//                } else if code == 1 {
//                    toAuth()
//                } else if code == 2 {
//                    presentAlert(message: "서버 문제입니다. 관계자에게 문의하세요.")
//                }
//            })
//            .disposed(by: rx.disposeBag)

    }
    
    /*
     code
     0 : Success
     1 : unValid
     2 : ServerError
     */
    
    //MARK: TODO - 고칠 것
    
    private func checkUserValid() -> Observable<Int> {
        Observable.create() { [unowned self] observable in
            if let uuid = Auth.auth().currentUser?.uid {

                AuthManager.shared.fetch(uuid: uuid)
                    .subscribe { [unowned self] in
                        CampaignManager.shared.fetch()
                            .subscribe {
                                observable.onNext(0)
                            } onError: { error in
                                print(error)
                                observable.onNext(2)
                            }
                            .disposed(by: rx.disposeBag)
                    } onError: { err in
                        
                        print(err)
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
                let vc = MainTabBarController()
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            } onError: { [unowned self] error in
                print(error)
                let vc = MainTabBarController()
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
            .disposed(by: rx.disposeBag)


    }

    private func toAuth() {
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
                    if let user = MyUserModel(data: userData) {
                        print(user.name)

                        
                        
                        userCount += 1
                        if user.bestImages.count > 0 {
                            bestImageCount += 1
                        }
                        
                        if let _ = user.igModel {
                            igCount += 1
                        }
                    }
                }
                
                Database.database().reference().child("appInfo").child("총유저수").setValue("\(userCount)명")
                Database.database().reference().child("appInfo").child("인스타연동계정수").setValue("\(igCount)명")
                Database.database().reference().child("appInfo").child("대표사진등록계정수").setValue("\(bestImageCount)명")
            }
    }
}
