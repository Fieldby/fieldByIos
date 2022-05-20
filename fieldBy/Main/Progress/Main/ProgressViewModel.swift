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
        
        var campaignArray = [(CampaignModel, UserCampaignModel)]()
        
        for campaign in AuthManager.shared.myUserModel.campaigns {
            
            CampaignManager.shared.fetchByUuid(uuid: campaign.uuid)
                .subscribe { [unowned self] model in
                    campaignArray.append((model, campaign))
                    var campaign2 = campaign
                    campaign2.status = .done
                    campaignArray.append((model, campaign2))
                    tosShowArray.accept(campaignArray)
                } onError: { err in
                    print(err)
                }
                .disposed(by: rx.disposeBag)
            
        }
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
}
