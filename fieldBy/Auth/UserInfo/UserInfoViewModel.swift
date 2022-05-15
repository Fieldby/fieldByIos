//
//  UserInfoViewModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/14.
//

import RxSwift
import RxCocoa
import NSObject_Rx

class UserInfoViewModel: NSObject {
    
    let nickNameSubject = BehaviorSubject<String>(value: "")
    let nickNameValidSubject = BehaviorSubject<Bool>(value: false)
    
    let jobSubject = BehaviorSubject<String>(value: "")
    let jobValidSubject = BehaviorSubject<Bool>(value: false)
    
    let birthDaySubject = BehaviorSubject<String>(value: "")
    let birthDayValidSubject = BehaviorSubject<Bool>(value: false)
    
    let heightSubject = BehaviorSubject<String>(value: "")
    let heightValidSubject = BehaviorSubject<Bool>(value: false)
    
    let regions = ["서울", "경기", "인천", "부산", "대구", "울산", "세종", "광주", "강원", "충남", "충북", "경남", "경북", "전남", "전북", "제주"]
    
    var selectedIndex: Int? = nil
    
    var pushGolfInfoVC: (() -> Void)!
    
    override init() {
        super.init()
        
        nickNameSubject
            .map { $0.count > 1 && $0.count < 8 }
            .bind(to: nickNameValidSubject)
            .disposed(by: rx.disposeBag)
        
        jobSubject
            .map { $0.count > 1 && $0.count < 10 }
            .bind(to: jobValidSubject)
            .disposed(by: rx.disposeBag)
        
        birthDaySubject
            .map { return Int($0) != nil && $0.count == 8 }
            .bind(to: birthDayValidSubject)
            .disposed(by: rx.disposeBag)
        
        heightSubject
            .map { return Int($0) != nil && 100 < Int($0)! && Int($0)! < 230 }
            .bind(to: heightValidSubject)
            .disposed(by: rx.disposeBag)
            
    }
    
    func saveInfo() {
        Observable.combineLatest(nickNameSubject, jobSubject, birthDaySubject, heightSubject)
            .subscribe(onNext: { [unowned self] nickName, job, birthDay, height in
                
                //MARK: 유저 정보 저장
                AuthManager.saveUserInfo(key: "nickName", value: nickName)
                AuthManager.saveUserInfo(key: "job", value: job)
                AuthManager.saveUserInfo(key: "birthDay", value: birthDay)
                AuthManager.saveUserInfo(key: "height", value: height)
                AuthManager.saveUserInfo(key: "simpleAddress", value: regions[selectedIndex!])
                
            })
            .disposed(by: rx.disposeBag)
    }
}
