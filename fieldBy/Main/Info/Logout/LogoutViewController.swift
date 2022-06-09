//
//  LogoutViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/06/09.
//

import UIKit

class LogoutViewController: UIViewController {

    static let storyId = "logoutVC"
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var text: UILabel!
    
    var reason: String!
    
    var titleText: String!
    var isSigningOut = false
    var topVC: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logoutButton.layer.cornerRadius = 13
        dismissButton.layer.cornerRadius = 13
        container.layer.cornerRadius = 13
        
        if let titleText = titleText {
            text.text = titleText
        }
        
        dismissButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                dismiss(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        logoutButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if isSigningOut {
                    AuthManager.shared.delete(reason: reason)
                    self.dismiss(animated: true) { [unowned self] in
                        topVC.dismiss(animated: true) {
                            AuthManager.shared.mainTabBar.dismiss(animated: true)
                        }
                    }
                } else {
                    AuthManager.shared.logOut()
                    self.dismiss(animated: true) {
                        AuthManager.shared.mainTabBar.dismiss(animated: true)
                    }
                }

            })
            .disposed(by: rx.disposeBag)
        
        
    }
    

}
