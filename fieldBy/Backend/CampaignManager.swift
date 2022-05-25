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

class CampaignManager: CommonBackendType {
    
    static let shared = CampaignManager()
    
    let campaignArrayRelay = BehaviorRelay<[CampaignModel]>(value: [])
    var campaignArray = [CampaignModel]()
    
    let path = "/campaigns"
    
    func fetch() -> Completable {
        return Completable.create() { [unowned self] completable in
         
            ref.child(path).observeSingleEvent(of: .value) { [unowned self] dataSnapShot in
                var campaignArray = [CampaignModel]()
                for data in dataSnapShot.children.allObjects as! [DataSnapshot] {
                    
                    if let campaignModel = CampaignModel(snapshot: data) {
                        campaignArray.append(campaignModel)
                    }
                }
                campaignArrayRelay.accept(campaignArray)
                self.campaignArray = campaignArray
                completable(.completed)
            }
                
            return Disposables.create()
        }
    }
    
    func guideImages(campaignModel: CampaignModel) -> Observable<[UIImage]> {
        return Observable.create() { [unowned self] observable in
            var images = [UIImage](repeating: UIImage(systemName: "pencil")!, count: campaignModel.guides.count)
            for i in 0..<campaignModel.guides.count {
                storageRef.child("campaignImages").child(campaignModel.uuid).child("guideImages").child(campaignModel.guides[i].imageUrl)
                    .getData(maxSize: 1024 * 1024) { data, error in
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
    
    func save(uuid: String, size: String?, color: String?) {
        let myUid = AuthManager.shared.myUserModel.uuid!
        
        ref.child("campaigns/\(uuid)/users").child(myUid).setValue(myUid)
        
//        ref.child("campaigns/\(uuid)/users").observeSingleEvent(of: .value) { [unowned self] dataSnapShot in
//            if dataSnapShot.exists() {
//                let idx = Int((dataSnapShot.children.allObjects as! [DataSnapshot]).last!.key)!
//                ref.child("campaigns/\(uuid)/users").child("\(idx+1)").setValue(myUid)
//
//            } else {
//                ref.child("campaigns/\(uuid)/users").child("0").setValue(myUid)
//            }
//
//        }
        ref.child("users").child(AuthManager.shared.myUserModel.uuid).child("campaigns").child(uuid).setValue(["size": size ?? "free", "color": color ?? "free"])

        if let model = model(uuid: uuid) {
            model.users[myUid] = true
            campaignArrayRelay.accept(campaignArray)
        }
        
        AuthManager.shared.addCampaign(uuid: uuid, size: size, color: color)
        
        
    }
    
    func model(uuid: String) -> CampaignModel? {
        return campaignArray.first { $0.uuid == uuid }
    }
    
    func cancel(uuid: String) -> Completable {
        return Completable.create() { [unowned self] completable in
            let myUid = AuthManager.shared.myUserModel.uuid!
            if let model = model(uuid: uuid) {
                model.users[myUid] = nil
            }
            
            ref.child("campaigns").child(uuid).child("users").child(myUid).removeValue() { err, ref in
                if let err = err {
                    completable(.error(err))
                }
                AuthManager.shared.removeCampaign(uuid: uuid) {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
}
