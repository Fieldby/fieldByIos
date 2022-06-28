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
    let birthDay: String?
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
    var juso: Juso
    var token: String?
    var fcmToken: String?
    let style: [Style]
    var reward: Int
    
    var igModel: IGModel?
    
    var campaigns: [UserCampaignModel] = []
    var campaignUuids: [String: Bool] = [:]
    var selectedCampaigns: [String: Bool] = [:]
    
    
    init?(data: DataSnapshot) {
        let value = data.value as! [String: Any]
        self.uuid = data.key
        
        if let career = value["career"] as? String,
           let height = value["height"] as? Int,
           let isPro = value["isPro"] as? Bool,
           let job = value["job"] as? String,
           let marketingAgreement = value["marketingAgreement"] as? Bool,
           let name = value["name"] as? String,
           let nickName = value["nickName"] as? String,
           let phoneNumber = value["phoneNumber"] as? String,
           let roundingFrequency = value["roundingFrequency"] as? String,
           let simpleAddress = value["simpleAddress"] as? String,
           let stroke = value["stroke"] as? String,
           let reward = value["reward"] as? String {
            
            self.birthDay = value["birthDay"] as? String
            self.career = Career(rawValue: career)!
            self.height = height
            self.isPro = isPro
            self.job = job
            self.marketingAgreement = marketingAgreement
            self.name = name
            self.nickName = nickName
            self.phoneNumber = phoneNumber
            self.roundingFrequency = RoundingCount(rawValue: roundingFrequency)!
            self.simpleAddress = simpleAddress
            self.stroke = StrokeAverage(rawValue: stroke)!
            self.reward = Int(reward)!
            
        } else {
            return nil
        }
        
        self.token = value["token"] as? String
        self.fcmToken = value["fcmToken"] as? String
        
        if data.childSnapshot(forPath: "address").exists() {
            let datasnapshot = data.childSnapshot(forPath: "address")
            self.juso = Juso(snapshot: datasnapshot)!
        } else { return nil }
        
        if let styleValue = data.childSnapshot(forPath: "styles").value as? [String] {
            style = styleValue.map{Style(rawValue: $0)!}
        } else { return nil }
        
        
        let igValue = data.childSnapshot(forPath: "igInfo")
        if igValue.exists() {
            igModel = IGModel(snapshot: igValue)
        }
        
        if let userCampaignValue = data.childSnapshot(forPath: "campaigns").children.allObjects as? [DataSnapshot] {
            if !userCampaignValue.isEmpty {
                var temp: [UserCampaignModel] = []
                
                for snapshot in userCampaignValue {
                    let model = UserCampaignModel(snapshot: snapshot)!
                    temp.append(model)
                    campaignUuids[model.uuid] = true
                    if model.isSelected == true {
                        selectedCampaigns[model.uuid] = true
                    }
                }
                campaigns = temp
            }
        }
        
    }
}
