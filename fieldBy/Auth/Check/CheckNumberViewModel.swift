//
//  CheckNumberViewModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/02.
//

import RxSwift
import RxCocoa
import NSObject_Rx

class CheckNumberViewModel: NSObject {
    let codeSubject = BehaviorSubject<String>(value: "")
    let codeValidSubject = BehaviorSubject<Bool>(value: false)
    
    override init() {
        super.init()
        
        codeSubject.map { $0.count == 6 }
            .bind(to: codeValidSubject)
            .disposed(by: rx.disposeBag)
    }
    
}
