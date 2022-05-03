//
//  AuthManager.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/03.
//

import RxSwift
import RxCocoa
import NSObject_Rx
import Alamofire

class AuthManager: CommonBackendType {
    static let certificatedNumberPath = "/certificatedNumberList"
    static private let addressKey = "U01TX0FVVEgyMDIyMDUwMzE3MjM0NDExMjUzMDc="
    
    
    static func certificatedNumberList() -> Single<[String]> {
        return single(path: certificatedNumberPath, type: [String].self)
    }
    
    static func address(keyword: String) -> Single<JusoResponse> {
        return Single.create() { observable in
            let addressBaseUrl = "https://www.juso.go.kr/addrlink/addrLinkApi.do"
            let params: [String: Any] = ["confmKey": addressKey,
                                                "currentPage": "1",
                                                "countPerPage":"30",
                                                "keyword": keyword,
                                                "resultType": "json"]
            
            AF.request(addressBaseUrl, method: .get, parameters: params).responseJSON { response in
                
                if let value = response.value {
                    if let jusoResponse: JusoResponse = self.toJson(object: value) {
                        observable(.success(jusoResponse))
                    } else {
//                        observable(.error())
                        print("serialize error")
                    }
                }
            }

            return Disposables.create()
        }
    }
    
    private static func toJson<T: Decodable>(object: Any) -> T? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: object) {
            let decoder = JSONDecoder()
            
            if let result = try? decoder.decode(T.self, from: jsonData) {
                return result
            } else {
                return nil
            }
        } else {
          return nil
        }
    }
}
