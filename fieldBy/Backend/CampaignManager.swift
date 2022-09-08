//
//  CampaignManager.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/12.
//

import FirebaseStorage
import FirebaseDatabase
import RxSwift
import RxCocoa
import Alamofire
import UIKit

class CampaignManager: CommonBackendType {
    
    static let shared = CampaignManager()
    
    let campaignArrayRelay = BehaviorRelay<[CampaignModel]>(value: [])
    var campaignMainImage: [UIImage] = []
    
    var campaignArray = [CampaignModel]()
    
    var loadingPercentage = BehaviorSubject<CGFloat>(value: 0)
    
    let path = "/campaigns"
    
    func fetch() -> Completable {
        return Completable.create() { [unowned self] completable in
            fetchModel()
                .andThen(fetchMainImage())
                .subscribe {
                    completable(.completed)
                } onError: { error in
                    print(error)
                    completable(.error(error))
                }
                .disposed(by: rx.disposeBag)

            return Disposables.create()
        }
    }
    
    private func fetchModel() -> Completable {
        print("@@@@@ fetch MODEL ")
        return Completable.create() { [unowned self] completable in
         
            ref.child(path).observeSingleEvent(of: .value) { [unowned self] dataSnapShot in
                var campaignArray = [CampaignModel]()
                for data in dataSnapShot.children.allObjects as! [DataSnapshot] {
                    
                    if let campaignModel = CampaignModel(snapshot: data) {
                        campaignArray.append(campaignModel)
                    }
                }
                campaignArrayRelay.accept(campaignArray.sorted(by: { $0.priority > $1.priority }))
                self.campaignArray = campaignArray.sorted(by: { $0.priority > $1.priority })
                completable(.completed)
            }
                
            return Disposables.create()
        }
    }
    
    private func fetchMainImage() -> Completable {
        return Completable.create() { [unowned self] completable in
            let campaignList = campaignArray.filter { $0.status == .applied }
            var imageList = [UIImage?](repeating: nil, count: campaignList.count)
            var cnt: CGFloat = 0
            print("@@@ mainimage")
            for i in 0..<campaignList.count {
                
                storageRef.child(campaignList[i].mainImageUrl)
                    .downloadURL { [unowned self] url, error in
                        if let error = error {
                            print(error)
                            completable(.error(FetchError.decodingFailed))
                        }
                        
                        if let url = url {
                            print(url)
                            let data = try! Data(contentsOf: url)
                            let image = UIImage(data: data)!
                            
                            imageList[i] = image
                            print(imageList)
                            cnt += 1
                            loadingPercentage.onNext((cnt)/CGFloat(imageList.count))
                            
                            if !imageList.contains(nil) {
                                for image in imageList {
                                    self.campaignMainImage.append(image!)
                                }
                                completable(.completed)
                            }
                            
                        }
                    }
            }
            return Disposables.create()
        }
    }
    
    func subImageUrl(campaignModel: CampaignModel) -> Single<[URL]> {
        return Single.create() { [unowned self] observable in
                
            storageRef.child("campaignImages").child(campaignModel.title).child("mainImages")
                .listAll { result, error in
                    if let error = error {
                        
                        observable(.error(error))

                    } else {
                        
                        var temp = [URL]()
                        
                        for i in 0..<result.items.count {
                            
                            result.items[i].downloadURL { url, urlError in
                                if let urlError = urlError {
                                    observable(.error(urlError))
                                } else {
                                    temp.append(url!)
                                    
                                    if temp.count == result.items.count {
                                        observable(.success(temp.sorted(by: { $0.absoluteString < $1.absoluteString })))
                                    }
                                }
                            }
                        }
                        
                    }
                }
            return Disposables.create()
        }
    }
    
    func guideImages(campaignModel: CampaignModel) -> Observable<[UIImage]> {
        return Observable.create() { [unowned self] observable in
            var images = [UIImage](repeating: UIImage(systemName: "pencil")!, count: campaignModel.guides.count)
            for i in 0..<campaignModel.guides.count {
                storageRef.child("campaignImages").child(campaignModel.title).child("guideImages").child(campaignModel.guides[i].imageUrl)
                    .getData(maxSize: 4096 * 4096) { data, error in
                        if let error = error {
                            print(error)
                            observable.onError(FetchError.emptyData)
                        }
                        if let data = data {
                            images[i] = UIImage(data: data)!
                            
                            if !images.contains(UIImage(systemName: "pencil")!) {
                                observable.onNext(images)
                            }
                        }
                    }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchByUuid(uuid: String) -> Single<CampaignModel> {
        return Single.create() { [unowned self] observable in
         
            ref.child(path).child(uuid).observeSingleEvent(of: .value) { dataSnapshot in
                if dataSnapshot.exists() {
                    if let model = CampaignModel(snapshot: dataSnapshot) {
                        observable(.success(model))
                    } else {
                        observable(.error(FetchError.decodingFailed))
                    }
                } else {
                    observable(.error(FetchError.emptyData))
                }

            }
            
            
            return Disposables.create()
        }
    }
    
    func save(campaignModel: CampaignModel, size: String?, color: String?) {
        let myUid = AuthManager.shared.myUserModel.uuid!
        
        ref.child("campaigns/\(campaignModel.uuid)/users").child(myUid).setValue(myUid)
        ref.child("brands").child(campaignModel.brandUuid).child("campaigns").child(campaignModel.uuid).child("users").child(myUid).setValue(myUid)
        ref.child("users").child(AuthManager.shared.myUserModel.uuid).child("campaigns").child(campaignModel.uuid).setValue(["size": size ?? "free", "color": color ?? "free"])

        if let model = model(uuid: campaignModel.uuid) {
            model.users[myUid] = true
            campaignArrayRelay.accept(campaignArray)
        }
        
        AuthManager.shared.addCampaign(uuid: campaignModel.uuid, size: size, color: color)
    }
    
    func saveUploadIds(campaignUuid: String, ids: [String]) -> Completable {
        return Completable.create() { completable in
            
            self.ref.child("users").child(AuthManager.shared.myUserModel.uuid).child("campaigns").child(campaignUuid).child("images")
                .setValue(ids)
            
            if let model = AuthManager.shared.myUserModel.campaigns.first(where: {$0.uuid == campaignUuid}) {
                model.imageArray = ids
            }

            completable(.completed)
            return Disposables.create()
        }
    }
    
    func model(uuid: String) -> CampaignModel? {
        return campaignArray.first { $0.uuid == uuid }
    }
    
    func cancel(campaignModel: CampaignModel) -> Completable {
        return Completable.create() { [unowned self] completable in
            let myUid = AuthManager.shared.myUserModel.uuid!
            if let model = model(uuid: campaignModel.uuid) {
                model.users[myUid] = nil
            }
            
            ref.child("brands").child(campaignModel.brandUuid).child("campaigns").child(campaignModel.uuid).child("users").child(myUid).removeValue()
            ref.child("campaigns").child(campaignModel.uuid).child("users").child(myUid).removeValue() { err, ref in
                if let err = err {
                    completable(.error(err))
                }
                AuthManager.shared.removeCampaign(uuid: campaignModel.uuid) {
                    completable(.completed)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func isSelected(uuid: String) -> Single<Bool?> {
        return Single.create() { [unowned self] observable in
            
            ref.child("users").child(AuthManager.shared.myUserModel.uuid).child("campaigns").child(uuid).child("isSelected")
                .observeSingleEvent(of: .value) { dataSnapShot in
                    let value = dataSnapShot.value as? Bool
                    AuthManager.shared.myUserModel.selectedCampaigns[uuid] = value
                    observable(.success(value))
                }

            return Disposables.create()
        }
    }
    
    func saveAddress(uid: String, juso: Juso, detail: String) {
        ref.child("users").child(AuthManager.shared.myUserModel.uuid).child("campaigns").child(uid).child("address").setValue(["detail": detail, "jibunAddr": juso.jibunAddr, "roadAddr": juso.roadAddr, "zipNo": juso.zipNo])
        
        if let model = AuthManager.shared.myUserModel.campaigns.first(where: {$0.uuid == uid}) {
            model.juso = juso
            model.juso?.detail = detail
        }
    }
}
