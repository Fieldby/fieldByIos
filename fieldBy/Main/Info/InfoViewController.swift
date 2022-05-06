//
//  InfoViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/04.
//

import UIKit
import FBSDKLoginKit
import SnapKit

class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let loginButton = FBLoginButton()
            .then {
                $0.backgroundColor = .black
            }
        loginButton.delegate = self
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints {
            $0.width.height.equalTo(300)
            $0.centerX.centerY.equalToSuperview()
        }
        
    }
    
}

extension InfoViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
          print(error.localizedDescription)
          return
        }
        
        guard let result = result else {
            return
        }
        
        if result.isCancelled {
            print("취소!")
            
            return
        }
        
        print(result.token)
       
        
        
        return
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("로그아웃")
    }
    
    
}
