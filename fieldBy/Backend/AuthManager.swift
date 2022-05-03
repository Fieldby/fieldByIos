//
//  AuthManager.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/03.
//

import RxSwift
import RxCocoa
import NSObject_Rx

class AuthManager: CommonBackendType {
    static let certificatedNumberPath = "/certificatedNumberList"
    
    
    static func certificatedNumberList() -> Single<[String]> {
        return single(path: certificatedNumberPath, type: [String].self)
    }
}
