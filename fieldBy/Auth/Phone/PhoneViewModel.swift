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
    let isCertificatedSubject = BehaviorSubject<Bool>(value: false)
    
    let nameSubject = BehaviorSubject<String>(value: "")
    let nameValidSubject = BehaviorSubject<Bool>(value: false)
    
    var presentCheckNumberVC: (() -> ())!
    
    override init() {
        super.init()
        
        numberSubject.map { return Int($0) != nil && $0.count == 11 }
            .bind(to: numberValidSubject)
            .disposed(by: rx.disposeBag)
        
        nameSubject.map { return $0.count > 1 && $0.count < 6 }
            .bind(to: nameValidSubject)
            .disposed(by: rx.disposeBag)
            
            
    }
    
    
    
}
