//
//  NotiViewModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/27.
//

import RxSwift
import RxCocoa
import NSObject_Rx

class NotiViewModel: NSObject {
    let notiArray = BehaviorRelay<[NotiModel]>(value: [])
    
    override init() {
        super.init()
        fetch()
    }
    
    func fetch() {
        NotiManager.shared.notiArray
            .bind(to: notiArray)
            .disposed(by: rx.disposeBag)

    }
}
