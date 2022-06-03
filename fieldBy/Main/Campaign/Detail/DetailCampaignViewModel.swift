//
//  DetailCampaignViewModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/12.
//

import FirebaseStorage
import RxSwift
import NSObject_Rx
import RxRelay

class DetailCampaignViewModel: NSObject {
    var pushGuideVC: (() -> Void)!
    var presentPopup: ((String) -> Void)!
    
    let imageUrlRelay = BehaviorRelay<[URL]>(value: [])
    
    func fetchImage(uuid: String) {
        CampaignManager.shared.mainImageUrl(campaignUuid: uuid)
            .subscribe { [unowned self] urlArr in
                imageUrlRelay.accept(urlArr)
            } onError: { err in
                print(err)
            }
            .disposed(by: rx.disposeBag)

    }
}
