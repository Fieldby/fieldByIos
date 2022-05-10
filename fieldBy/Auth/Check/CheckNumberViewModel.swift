//
//  CheckNumberViewModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/02.
//

import RxSwift
import RxCocoa
import NSObject_Rx
import FirebaseAuth

class CheckNumberViewModel: NSObject {
    let codeSubject = BehaviorSubject<String>(value: "")
    let codeValidSubject = BehaviorSubject<Bool>(value: false)
    
    var verifId: String?
        
    override init() {
        super.init()
        
        codeSubject.map { $0.count == 6 }
            .bind(to: codeValidSubject)
            .disposed(by: rx.disposeBag)
    }
    
    func verify(phoneNumber: String) {
        PhoneAuthProvider.provider()
            .verifyPhoneNumber("+82\(phoneNumber)", uiDelegate: nil) { [unowned self] verificationID, error in
                if let error = error {
                    print(error)
                }
                verifId = verificationID
            }
    }
    
    func login(sixCode: String) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verifId ?? "", verificationCode: sixCode)
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                print(error)
            }
            
            print("로그인 성공")
        }
    }

    

}
