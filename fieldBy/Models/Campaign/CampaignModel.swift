//
//  CampaignModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/12.
//

import FirebaseDatabase
import FirebaseStorage
import RxSwift
import RxCocoa


class CampaignModel: Codable {
    let imageUrl: String
    let brandUuid: String
    let brandName: String
    let isNew: Bool
    let itemModel: ItemModel
    
    let dueDate: String
    let selectionDate: String
    let itemDate: String
    let uploadDate: String
    
    let leastFeed: Int
    let maintain: Int
    
    
    init(url: String, brandUuid: String, isNew: Bool, itemModel: ItemModel, dueDate: String, selectionDate: String, itemDate: String, uploadDate: String, leastFeed: Int, maintain: Int, brandName: String) {
        self.imageUrl = url
        self.brandUuid = brandUuid
        self.isNew = isNew
        self.itemModel = itemModel
        self.dueDate = dueDate
        self.selectionDate = selectionDate
        self.itemDate = itemDate
        self.uploadDate = uploadDate
        self.leastFeed = leastFeed
        self.maintain = maintain
        self.brandName = brandName
    }
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        
        
        self.imageUrl = "campaignImages/\(snapshot.key)/\(value["imageUrl"] as! String)"
        self.brandUuid = value["brandUuid"] as! String
        self.isNew = value["isNew"] as! Bool
        
        self.dueDate = value["dueDate"] as! String
        self.selectionDate = value["selectionDate"] as! String
        self.itemDate = value["itemDate"] as! String
        self.uploadDate = value["uploadDate"] as! String
        self.leastFeed = value["leastFeed"] as! Int
        self.maintain = value["maintain"] as! Int
        self.brandName = value["brandName"] as! String
        
        let itemValue = snapshot.childSnapshot(forPath: "item").value as! [String: Any]
        self.itemModel = ItemModel(name: itemValue["name"] as! String, description: itemValue["description"] as! String, price: itemValue["price"] as! Int)
        
    }
    
}

struct ItemModel: Codable {
    let name: String
    let description: String
    let price: Int
}
