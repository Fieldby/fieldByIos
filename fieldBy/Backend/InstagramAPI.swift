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
    
    static var igToken: String!
    
    private var token: String {
        return InstagramAPI.igToken
    }
    
    case igLogin(viewController: UIViewController, token: String)
    case getFbID
    case getPageID
    case getIgID
    case getIgInfo
}

extension InstagramAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://graph.facebook.com/v13.0")!
    }
    
    var path: String {
        switch self {
        case .igLogin(_, _):
            return ""
        case .getFbID:
            return "/me/?access_token=\(token)"
        case .getPageID:
            return ""
        case .getIgID:
            return ""
        case .getIgInfo:
            return ""
        }
    }
    
    var method: Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
    
//    var validationType: ValidationType {
//        return .successCodes
//    }
}
