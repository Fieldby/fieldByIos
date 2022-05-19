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
import Firebase

class AuthManager: CommonBackendType {
    static let shared = AuthManager()
    
    var myUserModel: MyUserModel!
    
    var fbToken: String!
    var userUUID: String!
    static let certificatedNumberPath = "/certificatedNumberList"
    static private let addressKey = "U01TX0FVVEgyMDIyMDUwMzE3MjM0NDExMjUzMDc="
    
    func fetch(uuid: String) -> Completable {
        return Completable.create() { [unowned self] completable in
            
            ref.child("users").child(uuid)
                .observeSingleEvent(of: .value) { [unowned self] dataSnapShot in
                    if dataSnapShot.exists() {
                        if let myUserModel = MyUserModel(data: dataSnapShot) {
                            self.myUserModel = myUserModel
                            completable(.completed)
                        } else {
                            completable(.error(FetchError.decodingFailed))
                        }
                    } else {
                        completable(.error(FetchError.emptyData))
                    }
                    

                }
            
            return Disposables.create()
        }
    }
    
    func checkNumberValid(number: String) -> Observable<Bool> {
        return Observable.create() { [unowned self] observable in
            
            ref.child("certificatedNumberList").child(number)
                .observeSingleEvent(of: .value) { data in
                    if let bool = data.value as? Bool {
                        observable.onNext(bool)
                    } else {
                        observable.onNext(false)
                    }
                    
                }
            return Disposables.create()
            
        }
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
    
    static func saveUserInfo(key: String, value: Any) {
        voidPost(path: "users/\(AuthManager.shared.userUUID!)", key: key, value: value)
    }
    
    static func saveInfo(key: String, value: Any) -> Completable {
        return simplePost(path: "/users/\(AuthManager.shared.userUUID!)/\(key)", body: value)
    }
    
    static func saveAddressInfo(juso: Juso, detail: String) {
        Database.database().reference().child("users").child(AuthManager.shared.userUUID).child("address").setValue(["zipNo": juso.zipNo, "roadAddr": juso.roadAddr, "jibunAddr": juso.jibunAddr])
        Database.database().reference().child("users").child(AuthManager.shared.userUUID).child("address/detail").setValue(detail)
    }
    
    static func fetchUserInfo() -> Observable<Bool> {
        Observable.create() { observable in
            
            observable.onNext(true)
            
            
            return Disposables.create()
        }
    }
    
    static func fbPage() {
        
        //https://graph.instagram.com/refresh_access_token
        //?grant_type=ig_refresh_token
        //&access_token={단기토큰}
        
        
//        let path = "https://graph.facebook.com/v13.0/me?access_token=\(MyUserModel.shared.token)"
        
//        let path = "https://graph.facebook.com/\(MyUserModel.shared.faceId)?fields=id,name,email,picture&access_token=\(MyUserModel.shared.token)"
//        let path = "https://graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token=\(MyUserModel.shared.igToken)"
//        let path = "https://graph.instagram.com/me?fields=id,caption&access_token=\(MyUserModel.shared.longToken)"
        let path = "https://api.instagram.com/oauth/authorize?"
        
        
//        let path = "https://graph.facebook.com/v13.0/\(MyUserModel.shared.faceId)?fields=instagram_business_account&access_token=\(MyUserModel.shared.token)"

        
        AF.request(path, method: .get)
            .responseString { response in
                switch response.result {
                case .success(let str):
                    
                    print(str)
                    
                    
                    
                case .failure(let err):
                    print(err)
                }
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
