//
//  MyUserModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/06.
//

import FBSDKLoginKit
import FirebaseDatabase

class MyUserModel {
    
    var uuid: String!
    let birthDay: String
    let career: Career
    let height: Int
    let isPro: Bool
    let job: String
    let marketingAgreement: Bool
    let name: String
    let nickName: String
    let phoneNumber: String
    let roundingFrequency: RoundingCount
    let simpleAddress: String
    let stroke: StrokeAverage
    let juso: Juso
    let style: [Style]
    
    var igModel: IGModel?
    
    
    
    init?(data: DataSnapshot) {
        let value = data.value as! [String: Any]
        
        self.uuid = data.key
        self.birthDay = value["birthDay"] as! String
        self.career = Career(rawValue: value["career"] as! String)!
        self.height = value["height"] as! Int
        self.isPro = value["isPro"] as! Bool
        self.job = value["job"] as! String
        self.marketingAgreement = value["marketingAgreement"] as! Bool
        self.name = value["name"] as! String
        self.nickName = value["nickName"] as! String
        self.phoneNumber = value["phoneNumber"] as! String
        self.roundingFrequency = RoundingCount(rawValue: value["roundingFrequency"] as! String)!
        self.simpleAddress = value["simpleAddress"] as! String
        self.stroke = StrokeAverage(rawValue: value["stroke"] as! String)!
        
        let addressValue = data.childSnapshot(forPath: "address").value as! [String: Any]
        self.juso = Juso(roadAddr: addressValue["roadAddr"] as! String, jibunAddr: addressValue["jibunAddr"] as! String, zipNo: addressValue["zipNo"] as! String, detail: addressValue["detail"] as! String)
        
        
        let styleValue = data.childSnapshot(forPath: "styles").value as! [String]
        style = styleValue.map{Style(rawValue: $0)!}
        
        let igValue = data.childSnapshot(forPath: "igInfo")
        if igValue.exists() {
            igModel = IGModel(snapshot: igValue)
        }
        
    }
    
    
    
}
