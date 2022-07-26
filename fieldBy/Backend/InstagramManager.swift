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
import UIKit
import Moya


final class InstagramManager: CommonBackendType {
    
    static let shared = InstagramManager()
    var clientId = "680555059873566"
    var clientSecret: String = "0ec06aa0ff8bea756cd49507fc9d6a9d"
    
    private let graphUrl = "https://graph.facebook.com/v13.0/"
    private var fbId: String!
    private var fbPageId: String!
    private var instagramId: String!
    private var longToken: String!
    private var token: String!
    private var viewController: UIViewController!
    
    private func parseUrl(path: String, token: String) -> String {
        return "\(graphUrl)\(path)?access_token=\(token)"
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
        self.viewController = viewController
        self.token = token

        getFacebookId()
            .andThen(getFbPageId())
            .andThen(getInstagramId())
            .andThen(getFinalInfo())
            .subscribe {
                print("IG 연동 성공")
                completion()
            }
            .disposed(by: rx.disposeBag)
    }
    
    //페이지 접근 토큰, 내 id
    private func getFacebookId() -> Completable {
        return Completable.create() { [unowned self] completable in
            let url = parseUrl(path: "me/", token: token)
            getSingle(url: url, type: FBInfo.self)
                .subscribe { [unowned self] data in
                    fbId = data.id
                    completable(.completed)
                } onError: { [unowned self] err in
                    viewController.presentErrorAlert(message: "에러 1001: 올바르지 않은 페이스북 계정입니다. 페이스북 계정을 확인해주세요.", viewController: viewController)
                    completable(.error(err))
                }
                .disposed(by: rx.disposeBag)
            return Disposables.create()
        }
    }
    
    private func getFbPageId() -> Completable {
        return Completable.create() { [unowned self] completable in
            let url = parseUrl(path: "\(fbId!)/accounts/", token: token)
            getSingle(url: url, type: FBPageList.self)
                .subscribe { [unowned self] data in
                    if !data.data.isEmpty {
                        fbPageId = data.data.first!.id
                        completable(.completed)
                    } else {
                        viewController.presentErrorAlert(message: "에러 1002-1: 비즈니스 계정에 연결된 페이스북 페이지가 존재하지 않습니다.", viewController: viewController)
                        completable(.error(FetchError.emptyData))
                    }
                } onError: { [unowned self] err in
                    viewController.presentErrorAlert(message: "에러 1002-2: 페이스북 페이지를 생성하고 필드바이에 연결해주세요.", viewController: viewController)
                    completable(.error(FetchError.decodingFailed))
                }
                .disposed(by: rx.disposeBag)
            return Disposables.create()
        }
    }
    
    private func getInstagramId() -> Completable {
        return Completable.create() { [unowned self] completable in
            let url = "\(graphUrl)\(fbPageId!)?fields=instagram_business_account&access_token=\(token!)"
            getSingle(url: url, type: IGData.self)
                .subscribe { [unowned self] data in
                    instagramId = data.igModel.id
                    completable(.completed)
                } onError: { [unowned self] error in
                    viewController.presentErrorAlert(message: "에러 1003-2: 페이스북 페이지에 인스타그램 비즈니스 계정을 연결해주세요.", viewController: viewController)
                    completable(.error(error))
                }
                .disposed(by: rx.disposeBag)
            return Disposables.create()
        }
    }
    
    private func getFinalInfo() -> Completable {
        return Completable.create() { [unowned self] completable in
            let url = "\(graphUrl)\(instagramId!)?fields=name,username,profile_picture_url,followers_count,follows_count,media_count&access_token=\(token!)"
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
    
    func getMediaList() -> Single<[IGMediaModel]> {
        return Single.create() { [unowned self] single in
            guard let igModel = AuthManager.shared.myUserModel.igModel else {
                single(.error(FetchError.tokenError))
                return Disposables.create()
            }
            let igId = igModel.id
            let url = "\(graphUrl)\(igId)/media?fields=media_type,media_url,thumbnail_url&access_token=\(igModel.token!)"
            AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .responseData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        if let mediaData = decode(jsonData: data, type: IGMediaArrayModel.self) {
                            single(.success(mediaData.data))
                        } else {
                            print("feedids decodingFailed")
                            single(.error(FetchError.decodingFailed))
                        }
                    case .failure(let error):
                        single(.error(error))
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
    
//    func fetchChildImages(id: String, completion: @escaping ([ImageData]) -> ()) {
//        fetchChildren(id: id)
//            .subscribe { [unowned self] array in
//                fetchUrl(ids: array)
//                    .subscribe { imageArray in
//                        completion(imageArray)
//                    } onError: { err in
//                        print(err)
//                    }
//                    .disposed(by: rx.disposeBag)
//
//            } onError: { err in
//                print(err)
//            }
//            .disposed(by: rx.disposeBag)
//    }

    
    //feed Id -> child Id list
//    func fetchChildren(id: String) -> Single<[String]> {
//        return Single.create() { [unowned self] observable in
//            guard let igModel = AuthManager.shared.myUserModel.igModel else {
//                observable(.error(FetchError.tokenError))
//                return Disposables.create()
//            }
//
//            let url = "\(graphUrl)\(id)?fields=children&access_token=\(igModel.token!)"
//
//            AF.request(url, method: .get)
//                .validate(statusCode: 200..<300)
//                .responseData { [unowned self] response in
//                    switch response.result {
//                    case .success(let data):
//                        if let childrenData = decode(jsonData: data, type: ChildrenData.self) {
//                            var temp = [String]()
//                            for data in childrenData.children.data {
//                                temp.append(data.id)
//                            }
//                            observable(.success(temp))
//                        } else {
//                            if let childId = decode(jsonData: data, type: ChildId.self) {
//                                observable(.success([childId.id]))
//                            }
//                        }
//                    case .failure(let error):
//                        observable(.error(error))
//                    }
//                }
//
//            return Disposables.create()
//        }
//    }
    
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
