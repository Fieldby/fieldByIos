//
//  ProgressViewModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/20.
//

import RxSwift
import RxCocoa
import NSObject_Rx

class ProgressViewModel: NSObject {
    
    let tosShowArray = BehaviorRelay<[(CampaignModel, UserCampaignModel)]>(value: [])
    
    override init() {
        super.init()

    }
    
    func fetch() -> Completable {
        return Completable.create() { [unowned self] completable in
            var campaignArray = [(CampaignModel, UserCampaignModel)]()

            if campaignArray.isEmpty {
                completable(.completed)
            }
            
            for campaign in AuthManager.shared.myUserModel.campaigns {
                
                CampaignManager.shared.fetchByUuid(uuid: campaign.uuid)
                    .subscribe { [unowned self] model in
                        campaignArray.append((model, campaign))
                        tosShowArray.accept(campaignArray)
                        
                        if campaignArray.count == AuthManager.shared.myUserModel.campaigns.count {
                            completable(.completed)
                        }
                    } onError: { err in
                        completable(.error(err))
                    }
                    .disposed(by: rx.disposeBag)
                
            }
            
            
            
            
            return Disposables.create()
        }

    }
    
    
    
    
    
    
    
    
}
