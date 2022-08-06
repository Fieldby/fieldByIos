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
    var juso: Juso?
    var imageArray: [String] = []
    
    var shipmentName: String?
    var shipmentNumber: String?
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        self.uuid = snapshot.key
        self.size = value["size"] as? String
        self.color = value["color"] as? String
        self.isSelected = value["isSelected"] as? Bool
        self.shipmentName = value["shipment_name"] as? String
        self.shipmentNumber = value["shipment_number"] as? String
        
        if snapshot.childSnapshot(forPath: "images").exists() {
            imageArray = snapshot.childSnapshot(forPath: "images").value as! [String]

        }
        
        if snapshot.childSnapshot(forPath: "address").exists() {
            self.juso = Juso(snapshot: snapshot.childSnapshot(forPath: "address"))
        }
        

        
    }
    
    init(uuid: String, size: String?, color: String?) {
        self.uuid = uuid
        self.size = size
        self.color = color
    }
}
