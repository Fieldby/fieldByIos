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
    
    let notiArray = BehaviorRelay<[NotiModel]>(value: [])
    
    private override init() {
        super.init()
        
        fetch()
            .bind(to: notiArray)
            .disposed(by: rx.disposeBag)
    }
    
    func setToken(token: String) {
        if let token = AuthManager.shared.myUserModel.fcmToken {
            if token != token {
                AuthManager.saveUserInfo(key: "fcmToken", value: token)
            }
        } else {
            AuthManager.saveUserInfo(key: "fcmToken", value: token)
        }
    }
    
    private func fetch() -> Observable<[NotiModel]> {
        return Observable.create() { [unowned self] observable in
            let uid = AuthManager.shared.myUserModel!.uuid!

            ref.child("users").child(uid).child("noti").observe(.value) { snapshot in
                var temp = [NotiModel]()
                if snapshot.exists() {
                    for data in snapshot.children.allObjects as! [DataSnapshot] {
                        if let notiModel = NotiModel(snapshot: data) {
                            temp.append(notiModel)
                        }
                    }
                    
                    observable.onNext(temp.sorted(by: { $0.time > $1.time }))
                } else {
                    observable.onNext([])
                }
            }

            return Disposables.create()
        }
    }
    
    func sendInstagram() {
        let uid = AuthManager.shared.myUserModel!.uuid!
        let key = ref.child("users").child(uid).child("noti").childByAutoId().key!
        
        ref.child("users").child(uid).child("noti").child(key).setValue(["type": "instagram", "checked": false, "time": Date().notiDate])
        
    }
    
    func sendCampaignApplied(campaignModel: CampaignModel) {
        let uid = AuthManager.shared.myUserModel!.uuid!
        let key = ref.child("users").child(uid).child("noti").childByAutoId().key!
        
        campaignModel.getMainImageUrl()
            .subscribe { [unowned self] url in
                ref.child("users").child(uid).child("noti").child(key).setValue(["type": "campaignApplied", "checked": false, "targetUuid": campaignModel.uuid, "time": Date().notiDate, "title": campaignModel.title, "url": url])
            } onError: { _ in
                
            }
            .disposed(by: rx.disposeBag)

        

    }
    
    func read(notiUid: String) {
        let uid = AuthManager.shared.myUserModel!.uuid!
        ref.child("users").child(uid).child("noti").child(notiUid).child("checked").setValue(true)
    }
    
    func delete(notiUid: String) {
        let uid = AuthManager.shared.myUserModel!.uuid!
        ref.child("users").child(uid).child("noti").child(notiUid).removeValue()
    }
    
    
}
