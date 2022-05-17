//
//  CampaignManager.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/12.
//

import FirebaseStorage
import RxSwift
import RxCocoa

class CampaignManager: CommonBackendType {
    
    static let shared = CampaignManager()
    
    func fetch() -> Completable {
        return Completable.create() { completable in
         
            
            return Disposables.create()
        }
    }
    
}
