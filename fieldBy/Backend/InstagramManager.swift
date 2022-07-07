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
    var clientId: String = "680555059873566"
    var clientSecret: String = "0ec06aa0ff8bea756cd49507fc9d6a9d"
    
    private let graphUrl = "https://graph.facebook.com/v13.0/"
    private var fbId: String!
    private var fbPageId: String!
    private var instagramId: String!
    private var longToken: String!
    
    func decode<T: Decodable>(jsonData: Data, type: T.Type) -> T? {
        do {
            let data = try JSONDecoder().decode(type.self, from: jsonData)
            return data
        } catch {
            return nil
        }
    }
    
    func getLongToken(token: String) -> Single<String> {
        return Single.create() { [unowned self] observable in
            
            let url = graphUrl + "oauth/access_token?grant_type=fb_exchange_token&client_id=\(clientId)&client_secret=\(clientSecret)&fb_exchange_token=\(token)"
            
            AF.request(url, method: .get)
                .responseData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        if let data = decode(jsonData: data, type: TokenModel.self) {
                            longToken = data.accessToken
                            observable(.success(longToken))
                        } else {
                            observable(.error(FetchError.decodingFailed))
                        }
                    case .failure(let err):
                        observable(.error(err))
                    }
                }

            return Disposables.create()
        }
    }
    
    func igLogin(viewController: UIViewController, token: String, completion: @escaping () -> ()) {
        facebookId(token: token)
            .subscribe { [unowned self] in
                print("token \(token)")
                fbPageId(token: token)
                    .subscribe { [unowned self] in
                        instagramId(token: token)
                            .subscribe { [unowned self] in
                                finalInfo(token: token)
                                    .subscribe { [unowned self] in
                                        print("IG 연동 성공")
                                        completion()
                                    } onError: { err in
                                        print("final\(err)")
                                    }
                                    .disposed(by: rx.disposeBag)

                            } onError: { err in
                                print("igId\(err)")
                                viewController.presentErrorAlert(message: "에러 1003: 페이스북 페이지에 인스타그램 비즈니스 계정을 연결해주세요.", viewController: viewController)
                            }
                            .disposed(by: rx.disposeBag)

                    } onError: { err in
                        print("fbpageid\(err)")
                        viewController.presentErrorAlert(message: "에러 1002: 페이스북 페이지를 생성하고 필드바이에 연결해주세요.", viewController: viewController)
                    }
                    .disposed(by: rx.disposeBag)
            } onError: { err in
                print("fbid\(err)")
                viewController.presentErrorAlert(message: "에러 1001: 페이스북 로그인에 실패했습니다.", viewController: viewController)
            }
            .disposed(by: rx.disposeBag)
 

    }
    
    private func parseUrl(path: String, token: String) -> String {
        return "\(graphUrl)\(path)?access_token=\(token)"
    }
    
    //페이지 접근 토큰, 내 id
    private func facebookId(token: String) -> Completable {
        
        return Completable.create() { [unowned self] completable in
            let url = parseUrl(path: "me/", token: token)
            
            AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .responseData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        if let data = decode(jsonData: data, type: FBInfo.self) {
                            self.fbId = data.id
                            print(self.fbId)
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
    
    private func fbPageId(token: String) -> Completable {
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
    
    private func instagramId(token: String) -> Completable {
        return Completable.create() { [unowned self] completable in
            let url = "\(graphUrl)\(fbPageId!)?fields=instagram_business_account&access_token=\(token)"
            
            AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .responseData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        if let data = decode(jsonData: data, type: IGData.self) {
                            self.instagramId = data.igModel.id
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
    
    private func finalInfo(token: String) -> Completable {
        return Completable.create() { [unowned self] completable in
            let url = "\(graphUrl)\(instagramId!)?fields=name,username,profile_picture_url,followers_count,follows_count,media_count&access_token=\(token)"
            
            AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .responseData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        if var data = decode(jsonData: data, type: IGModel.self) {
                            data.token = token
                            AuthManager.shared.addIGInfo(igModel: data)
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
    
    private func feedIds() -> Single<[String]> {
        
        return Single.create() { [unowned self] observable in
            guard let igModel = AuthManager.shared.myUserModel.igModel else {
                observable(.error(FetchError.tokenError))
                return Disposables.create()
            }
            
            let igId = igModel.id
            
            
            let url = "\(graphUrl)\(igId)?fields=media&access_token=\(igModel.token!)"
            
            AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .responseData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        if let mediaData = decode(jsonData: data, type: MediaData.self) {
                            var temp = [String]()
                            for mediaId in mediaData.media.data {
                                temp.append(mediaId.id)
                            }
                            observable(.success(temp))
                        } else {
                            print("feedids decodingFailed")
                            observable(.error(FetchError.decodingFailed))
                        }
                    case .failure(let error):
                        observable(.error(error))
                    }
                }
            return Disposables.create()
        }
        
    }
    
    private func getImages(ids: [String]) -> Single<[ImageData]> {
        
        return Single.create() { [unowned self] observable in
            
            guard let igModel = AuthManager.shared.myUserModel.igModel else {
                observable(.error(FetchError.tokenError))
                return Disposables.create()
            }
            
            var temp = [ImageData]()
            
            for id in ids {
                let url = "\(graphUrl)\(id)?fields=media_url,timestamp,id,media_type&access_token=\(igModel.token!)"
                
                AF.request(url, method: .get)
                    .validate(statusCode: 200..<300)
                    .responseData { [unowned self] response in
                        switch response.result {
                        case .success(let data):
                            if let imageData = decode(jsonData: data, type: ImageData.self) {
                                temp.append(imageData)
                                if temp.count == ids.count {
                                    temp.sort(by: { $0.timestamp > $1.timestamp })
                                    observable(.success(temp))
                                }
                            } else {
                                temp.append(ImageData(id: "",mediaURL: "", timestamp: "", mediaType: .video))
                                if temp.count == ids.count {
                                    observable(.success(temp))
                                }
                            }
                        case .failure(let error):
                            print(error)
                            temp.append(ImageData(id: "", mediaURL: "", timestamp: "", mediaType: .video))
                            if temp.count == ids.count {
                                observable(.success(temp))
                            }
                        }
                    }
            }
            return Disposables.create()
        }
    }
    
    func fetchImages(completion: @escaping ([ImageData]) -> ()) {
        feedIds()
            .subscribe { [unowned self] idArray in
                getImages(ids: idArray)
                    .subscribe { imageArray in
                        completion(imageArray)
                    } onError: { err in
                        print(err)
                        completion([])
                    }
                    .disposed(by: rx.disposeBag)

            } onError: { err in
                print(err)
                completion([])
            }
            .disposed(by: rx.disposeBag)

    }
    
    func fetchChildImages(id: String, completion: @escaping ([ImageData]) -> ()) {
        fetchChildren(id: id)
            .subscribe { [unowned self] array in
                fetchUrl(ids: array)
                    .subscribe { imageArray in
                        completion(imageArray)
                    } onError: { err in
                        print(err)
                    }
                    .disposed(by: rx.disposeBag)

            } onError: { err in
                print(err)
            }
            .disposed(by: rx.disposeBag)
    }

    
    //feed Id -> child Id list
    func fetchChildren(id: String) -> Single<[String]> {
        return Single.create() { [unowned self] observable in
            guard let igModel = AuthManager.shared.myUserModel.igModel else {
                observable(.error(FetchError.tokenError))
                return Disposables.create()
            }

            let url = "\(graphUrl)\(id)?fields=children&access_token=\(igModel.token!)"
            
            AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .responseData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        if let childrenData = decode(jsonData: data, type: ChildrenData.self) {
                            var temp = [String]()
                            for data in childrenData.children.data {
                                temp.append(data.id)
                            }
                            observable(.success(temp))
                        } else {
                            if let childId = decode(jsonData: data, type: ChildId.self) {
                                observable(.success([childId.id]))
                            }
                        }
                    case .failure(let error):
                        observable(.error(error))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    private func fetchUrl(ids: [String]) -> Single<[ImageData]> {
        return Single.create() { [unowned self] observable in

            guard let igModel = AuthManager.shared.myUserModel.igModel else {
                observable(.error(FetchError.tokenError))
                return Disposables.create()
            }

            var temp = [ImageData]()

            for id in ids {
                let url = "\(graphUrl)\(id)?fields=media_url,timestamp,id,media_type&access_token=\(igModel.token!)"

                AF.request(url, method: .get)
                    .validate(statusCode: 200..<300)
                    .responseData { [unowned self] response in
                        switch response.result {
                        case .success(let data):
                            if let imageData = decode(jsonData: data, type: ImageData.self) {
                                temp.append(imageData)
                                if temp.count == ids.count {
                                    temp.sort(by: { $0.timestamp > $1.timestamp })
                                    observable(.success(temp))
                                }
                            } else {
                                temp.append(ImageData(id: "", mediaURL: "", timestamp: "", mediaType: .video))
                                if temp.count == ids.count {
                                    observable(.success(temp))
                                }
                            }
                        case .failure(let error):
                            print(error)
                            temp.append(ImageData(id: "", mediaURL: "", timestamp: "", mediaType: .video))
                            if temp.count == ids.count {
                                observable(.success(temp))
                            }
                        }
                    }
            }
            return Disposables.create()
        }
    }
}

