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
    
    func verify(phoneNumber: String) -> Completable {
        
        return Completable.create() { completable in
            
            PhoneAuthProvider.provider()
                .verifyPhoneNumber("+82\(phoneNumber)", uiDelegate: nil) { [unowned self] verificationID, error in
                    if let error = error {
                        completable(.error(error))
                    }
                    
                    if let verificationID = verificationID {
                        self.verifId = verificationID
                        completable(.completed)
                    }
                }

            return Disposables.create()
        }

    }
    
    func login(sixCode: String, phoneNumber: String) -> Completable {
        
        return Completable.create() { [unowned self] completable in
            guard let verifId = verifId else {
                return Disposables.create()
            }

            
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verifId, verificationCode: sixCode)
            
            Auth.auth().signIn(with: credential) { [unowned self] result, error in
                if let error = error {
                    print(error)
                    completable(.error(error))
                }
                
                if let result = result {
                    MyUserModel.shared.uuid = result.user.uid
                    
                    AuthManager.saveInfo(key: "phoneNumber", value: phoneNumber)
                        .subscribe {
                            completable(.completed)
                        } onError: { error in
                            completable(.error(error))
                        }
                        .disposed(by: rx.disposeBag)
                }

            }

            return Disposables.create()
        }

    }

    

}
