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

class DefaultViewController: UIViewController {
    
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()


        

    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkUserValid()
            .subscribe(onNext: { [unowned self] bool in
                bool ? toMain() : toAuth()
            })
            .disposed(by: rx.disposeBag)

    }
    
    private func checkUserValid() -> Observable<Bool> {
        Observable.create() { observable in
            
            if let uuid = Auth.auth().currentUser?.uid {
                
                AuthManager.shared.fetch(uuid: uuid)
                    .subscribe {
                        observable.onNext(true)
                    } onError: { err in
                        observable.onNext(false)
                    }
            }
            return Disposables.create()
        }
    }

    private func toMain() {
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
    
}
