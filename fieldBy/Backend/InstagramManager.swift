//
//  InstagramManager.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/08.
//

import Alamofire
import RxSwift
import RxCocoa
import NSObject_Rx
import ObjectiveC

class InstagramManager: NSObject {
    
    static let shared = InstagramManager()
    
    private let graphUrl = "https://graph.facebook.com/v13.0/"
    private var fbId: String!
    private var fbPageId: String!
    private var instagramId: String!
    
    func decode<T: Decodable>(jsonData: Data, type: T.Type) -> T? {
        do {
            let data = try JSONDecoder().decode(type.self, from: jsonData)
            return data
        } catch {
            return nil
        }
    }
    
    
    func fetchIGId(token: String) {
        facebookId(token: token)
            .subscribe { [unowned self] in
                
                fbPageId(token: token)
                    .subscribe { [unowned self] in
                        
                        instagramId(token: token)
                            .subscribe { [unowned self] in
                                print(instagramId!)
                            } onError: { err in
                                print(err)
                            }
                            .disposed(by: rx.disposeBag)

                    } onError: { err in
                        print(err)
                    }
                    .disposed(by: rx.disposeBag)
            } onError: { err in
                print(err)
            }
            .disposed(by: rx.disposeBag)
 

    }
    
    func parseUrl(path: String, token: String) -> String {
        return "\(graphUrl)\(path)?access_token=\(token)"
    }
    
    //페이지 접근 토큰, 내 id
    func facebookId(token: String) -> Completable {
        
        return Completable.create() { [unowned self] completable in
            let url = parseUrl(path: "me/", token: token)
            
            AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .responseData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        if let data = decode(jsonData: data, type: FBInfo.self) {
                            self.fbId = data.id
                            completable(.completed)
                        } else {
                            completable(.error(FetchError.decodingFailed))
                        }
                    case .failure(let error):
                        completable(.error(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func fbPageId(token: String) -> Completable {
        return Completable.create() { [unowned self] completable in
            let url = parseUrl(path: "\(fbId!)/accounts/", token: token)
            
            AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .responseData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        if let data = decode(jsonData: data, type: FBPageList.self) {
                            if !data.data.isEmpty {
                                self.fbPageId = data.data.first!.id
                                completable(.completed)
                            } else {
                                completable(.error(FetchError.emptyData))
                            }
                        } else {
                            completable(.error(FetchError.decodingFailed))
                        }
                    case .failure(let error):
                        completable(.error(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    func instagramId(token: String) -> Completable {
        return Completable.create() { [unowned self] completable in
            let url = "\(graphUrl)\(fbPageId!)?fields=instagram_business_account&access_token=\(token)"
            
            AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .responseData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        if let data = decode(jsonData: data, type: IGData.self) {
                            self.instagramId = data.instagramBusinessAccount.id
                            completable(.completed)
                        } else {
                            completable(.error(FetchError.decodingFailed))
                        }
                    case .failure(let error):
                        completable(.error(error))
                    }
                }
            return Disposables.create()
        }
    }
}

