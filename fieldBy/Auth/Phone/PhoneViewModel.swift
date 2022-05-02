//
//  PhoneViewModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/02.
//

import RxSwift
import RxCocoa
import NSObject_Rx

protocol PhoneViewModelType {
    func checkPhoneNumberValid()
    
}

class PhoneViewModel: NSObject {
    let numberSubject = BehaviorSubject<String>(value: "")
    let numberValidSubject = BehaviorSubject<Bool>(value: false)
    let isCertificatedSubject = BehaviorSubject<Bool>(value: false)
    
    override init() {
        super.init()
        
        numberSubject.map { return Int($0) != nil && $0.count == 11 }
            .bind(to: numberValidSubject)
            .disposed(by: rx.disposeBag)
            
            
    }
    
}
