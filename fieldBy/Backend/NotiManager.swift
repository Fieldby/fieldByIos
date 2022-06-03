//
//  NotiManager.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/27.
//

import RxSwift
import RxCocoa
import NSObject_Rx
import FirebaseDatabase

class NotiManager: CommonBackendType {
    static let shared = NotiManager()
    
    
    func fetch() -> Single<[NotiModel]> {
        return Single.create() { [unowned self] observable in
            let uid = AuthManager.shared.myUserModel!.uuid!
            var temp = [NotiModel]()
            
            ref.child("users").child(uid).child("noti").observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    for data in snapshot.children.allObjects as! [DataSnapshot] {
                        let notiModel = NotiModel(snapshot: data)!
                        temp.append(notiModel)
                    }
                    
                    observable(.success(temp))
                } else {
                    observable(.success([]))
                }
            }

            return Disposables.create()
        }
    }
    
    func sendInstagram() {
        let uid = AuthManager.shared.myUserModel!.uuid!
        let key = ref.child("users").child(uid).child("noti").childByAutoId().key!
        
        ref.child("users").child(uid).child("noti").child(key).setValue(["type": "instagram", "checked": false])
        
    }
}
