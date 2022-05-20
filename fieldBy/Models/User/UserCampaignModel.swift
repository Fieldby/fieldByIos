//
//  UserCampaignModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/20.
//

import FirebaseDatabase

struct UserCampaignModel: Codable {
    let uuid: String
    var status: CampaignStatus
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        self.uuid = snapshot.key
        self.status = CampaignStatus(rawValue: value["status"] as! String)!
    }
    
    
    enum CampaignStatus: String, Codable {
        case applied
        case delivering
        case uploaded
        case maintaining
        case done
    }
}
