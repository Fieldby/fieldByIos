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
                    let campaignModel = CampaignModel(snapshot: data)!
                    campaignArray.append(campaignModel)
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
}
