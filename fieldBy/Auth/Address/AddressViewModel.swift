//
//  AddressViewModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/03.
//

import RxSwift
import RxCocoa
import NSObject_Rx

class AddressViewModel: NSObject {
    let jusoSubject = BehaviorSubject<[Juso]>(value: [])
    
    override init() {
        super.init()
        
        
    }
    
    func search(keyword: String, completion: @escaping (() -> ())) {
        AuthManager.address(keyword: keyword)
            .subscribe { [unowned self] response in
                jusoSubject.onNext(response.results.juso)
                completion()
            } onError: { err in
                print(err)
            }
            .disposed(by: rx.disposeBag)

        
    }
    
}
