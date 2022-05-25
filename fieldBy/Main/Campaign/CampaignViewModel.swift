//
//  CampaignViewModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/12.
//

import Foundation
import RxRelay

class CampaignViewModel: NSObject {
    
    let campaignRelay = BehaviorRelay<[CampaignModel]>(value: [])
    
    
    func reload() {
        CampaignManager.shared.campaignArrayRelay
            .bind(to: campaignRelay)
            .disposed(by: rx.disposeBag)
    }
    
}
