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
                completable(.completed)
            }
                
            return Disposables.create()
        }
    }
}
