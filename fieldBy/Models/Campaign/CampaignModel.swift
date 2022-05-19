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
    let uuid: String
    let mainImageUrl: String
    let guides: [GuideModel]
    
    let brandUuid: String
    let brandName: String
    let brandInstagram: String
    
    let isNew: Bool
    let itemModel: ItemModel
    
    let dueDate: String
    let selectionDate: String
    let itemDate: String
    let uploadDate: String
    
    let leastFeed: Int
    let maintain: Int
    
    let hashTagModel: HashTagModel
    
    
    init(url: String, brandUuid: String, isNew: Bool, itemModel: ItemModel, dueDate: String, selectionDate: String, itemDate: String, uploadDate: String, leastFeed: Int, maintain: Int, brandName: String, guides: [GuideModel], uuid: String, brandInstagram: String, hashTagModel: HashTagModel) {
        self.mainImageUrl = url
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
        self.guides = guides
        self.uuid = uuid
        self.brandInstagram = brandInstagram
        self.hashTagModel = hashTagModel
    }
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        
        self.uuid = snapshot.key
        self.mainImageUrl = "campaignImages/\(snapshot.key)/\(value["mainImageUrl"] as! String)"
        self.brandUuid = value["brandUuid"] as! String
        self.isNew = value["isNew"] as! Bool
        
        self.dueDate = value["dueDate"] as! String
        self.selectionDate = value["selectionDate"] as! String
        self.itemDate = value["itemDate"] as! String
        self.uploadDate = value["uploadDate"] as! String
        self.leastFeed = value["leastFeed"] as! Int
        self.maintain = value["maintain"] as! Int
        self.brandName = value["brandName"] as! String
        self.brandInstagram = value["brandInstagram"] as! String
        
        let itemValue = snapshot.childSnapshot(forPath: "item").value as! [String: Any]
        self.itemModel = ItemModel(name: itemValue["name"] as! String, description: itemValue["description"] as! String, price: itemValue["price"] as! Int)
        
        var tempGuides = [GuideModel]()
        for data in snapshot.childSnapshot(forPath: "guides").children.allObjects as! [DataSnapshot] {
            let guideModel = GuideModel(snapshot: data)!
            tempGuides.append(guideModel)
        }
        self.guides = tempGuides
        
        
        self.hashTagModel = HashTagModel(snapshot: snapshot.childSnapshot(forPath: "hashTags"))!
    }
    
}

struct ItemModel: Codable {
    let name: String
    let description: String
    let price: Int
}

struct GuideModel: Codable {
    let imageUrl: String
    let description: String
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        self.imageUrl = value["imageUrl"] as! String
        self.description = value["description"] as! String
    }
}

struct HashTagModel: Codable {
    let ftc: String
    let option: String
    let required: String
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        self.ftc = value["ftc"] as! String
        self.option = value["option"] as! String
        self.required = value["required"] as! String
    }

}
