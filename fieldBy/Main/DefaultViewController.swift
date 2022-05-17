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

class DefaultViewController: UIViewController {
    
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()


        

    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        checkUserValid()
            .subscribe(onNext: { [unowned self] bool in
                print(bool)
                if bool {
                    toMain()
                } else {
//                    toAuth()
                    uiTest()
                }

            })
            .disposed(by: bag)

    }
    
    private func checkUserValid() -> Observable<Bool> {
        Observable.create() { observable in
            
            
            CampaignManager.shared.fetch()
                .subscribe {
                    print("good")
                } onError: { err in
                    print(err)
                }

            
            observable.onNext(true)
            
            
            return Disposables.create()
        }
    }

    private func toMain() {
        let vc = MainTabBarController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
