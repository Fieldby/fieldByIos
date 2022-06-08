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
    
    let toShowArray = BehaviorRelay<[(CampaignModel, UserCampaignModel)]>(value: [])
    
    var showStatus: ((Bool?, CampaignModel, UIImage) -> ())!
    
    override init() {
        super.init()

    }
    
    func fetch() -> Completable {
        return Completable.create() { [unowned self] completable in
            var campaignArray = [(CampaignModel, UserCampaignModel)]()

            if campaignArray.isEmpty {
                toShowArray.accept([])
                completable(.completed)
            }
            
            for campaign in AuthManager.shared.myUserModel.campaigns {
                
                CampaignManager.shared.fetchByUuid(uuid: campaign.uuid)
                    .subscribe { [unowned self] model in
                        campaignArray.append((model, campaign))
                        toShowArray.accept(campaignArray)
                        
                        if campaignArray.count == AuthManager.shared.myUserModel.campaigns.count {

                            AuthManager.shared.fetchCampaigns()
                                .subscribe {
                                    completable(.completed)
                                }
                                .disposed(by: rx.disposeBag)
                            
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
