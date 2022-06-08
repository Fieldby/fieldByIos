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
    
    func helpAction() {
        if let url = URL(string: "http://pf.kakao.com/_xdxeQzb") {
            UIApplication.shared.open(url)
        }
    }
}
