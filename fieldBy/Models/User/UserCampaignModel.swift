//
//  UserCampaignModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/20.
//

import FirebaseDatabase

class UserCampaignModel: Codable {
    let uuid: String
    var size: String?
    var color: String?
    var isSelected: Bool?
    var imageArray: [[String]] = [[]]
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        self.uuid = snapshot.key
        self.size = value["size"] as? String
        self.color = value["color"] as? String
        self.isSelected = value["isSelected"] as? Bool
        
        var temp = [[String]]()
        
        if snapshot.childSnapshot(forPath: "images").exists() {
            
            for array in snapshot.childSnapshot(forPath: "images").children.allObjects as! [DataSnapshot] {
                temp.append(array.value as! [String])
            }
        }

        self.imageArray = temp
        
    }
    
    init(uuid: String, size: String?, color: String?) {
        self.uuid = uuid
        self.size = size
        self.color = color
    }
}
