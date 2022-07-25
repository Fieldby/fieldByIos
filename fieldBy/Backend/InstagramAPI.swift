//
//  InstagramApi.swift
//  fieldBy
//
//  Created by 박진서 on 2022/07/25.
//

import Moya

enum InstagramAPI {
    private var clientId: String {
        return "680555059873566"
    }
    
    private var clientSecret: String {
        return "0ec06aa0ff8bea756cd49507fc9d6a9d"
    }
    
    case igLogin(viewController: UIViewController, token: String)
    case getFbID
    case getPageID
    case getIgID
    case getIgInfo
}
