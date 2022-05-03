//
//  PhoneViewModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/02.
//

import RxSwift
import RxCocoa
import NSObject_Rx

class PhoneViewModel: NSObject {
    let numberSubject = BehaviorSubject<String>(value: "")
    let numberValidSubject = BehaviorSubject<Bool>(value: false)
    
    let nameSubject = BehaviorSubject<String>(value: "")
    let nameValidSubject = BehaviorSubject<Bool>(value: false)
    
    let agreeAllSubject = PublishSubject<Bool>()
    
    let usageSubject = BehaviorSubject<Bool>(value: false)
    let privacySubject = BehaviorSubject<Bool>(value: false)
    let marketingSubject = BehaviorSubject<Bool>(value: false)
    
    
    var presentCheckNumberVC: (() -> ())!
    var pushFailedVC: (() -> ())!
    
    override init() {
        super.init()
        
        numberSubject.map { return Int($0) != nil && $0.count == 11 }
            .bind(to: numberValidSubject)
            .disposed(by: rx.disposeBag)
        
        nameSubject.map { return $0.count > 1 && $0.count < 6 }
            .bind(to: nameValidSubject)
            .disposed(by: rx.disposeBag)
        
        Observable.combineLatest(usageSubject, privacySubject, marketingSubject)
            .map { b1, b2, b3 -> Bool in
                if b1 == true && b2 == true && b3 == true {
                    return true
                }
                return false
            }
            .bind(to: agreeAllSubject)
            .disposed(by: rx.disposeBag)
            


            
    }
    
    func checkNumber() -> Observable<Bool> {
        
        return Observable.zip(AuthManager.certificatedNumberList().asObservable(), numberSubject)
            .map { list, number -> Bool in
                return list.contains(number)
            }


    }
    
    
    
}
