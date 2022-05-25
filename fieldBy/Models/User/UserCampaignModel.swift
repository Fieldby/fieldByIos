//
//  UserCampaignModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/20.
//

import FirebaseDatabase

struct UserCampaignModel: Codable {
    let uuid: String
    var size: String?
    var color: String?
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        self.uuid = snapshot.key
        self.size = value["size"] as? String
        self.color = value["color"] as? String
    }
    
    init(uuid: String, size: String?, color: String?) {
        self.uuid = uuid
        self.size = size
        self.color = color
    }
}
