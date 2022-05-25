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
    
    let recruitingDate: String
    let dueDate: String
    let selectionDate: String
    let itemDate: String
    let uploadDate: String
    let maintain: Int
    let leastFeed: Int

    
    let hashTagModel: HashTagModel
    
    var users: [String: Bool]
    
    var status: CampaignStatus = .unOpened
    
    
    
    init(url: String, brandUuid: String, isNew: Bool, itemModel: ItemModel, dueDate: String, selectionDate: String, itemDate: String, uploadDate: String, leastFeed: Int, maintain: Int, brandName: String, guides: [GuideModel], uuid: String, brandInstagram: String, hashTagModel: HashTagModel, users: [String: Bool], recruitingDate: String, status: CampaignStatus) {
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
        
        self.users = users
        self.recruitingDate = recruitingDate
        self.status = status
    }
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        
        self.uuid = snapshot.key
        
        if let imageUrl = value["mainImageUrl"] as? String,
           let brandUuid = value["brandUuid"] as? String,
           let isNew = value["isNew"] as? Bool {
            self.mainImageUrl = "campaignImages/\(self.uuid)/\(imageUrl)"
            self.brandUuid = brandUuid
            self.isNew = isNew
            
        } else {
            return nil
        }

        self.dueDate = value["dueDate"] as! String
        self.selectionDate = value["selectionDate"] as! String
        self.itemDate = value["itemDate"] as! String
        self.uploadDate = value["uploadDate"] as! String
        self.leastFeed = value["leastFeed"] as! Int
        self.maintain = value["maintain"] as! Int
        self.brandName = value["brandName"] as! String
        self.brandInstagram = value["brandInstagram"] as! String
        
        let itemValue = snapshot.childSnapshot(forPath: "item")
        self.itemModel = ItemModel(snapshot: itemValue)
        
        var tempGuides = [GuideModel]()
        for data in snapshot.childSnapshot(forPath: "guides").children.allObjects as! [DataSnapshot] {
            let guideModel = GuideModel(snapshot: data)!
            tempGuides.append(guideModel)
        }
        self.guides = tempGuides
        
        
        self.hashTagModel = HashTagModel(snapshot: snapshot.childSnapshot(forPath: "hashTags"))!
        
        var tempUsers: [String: Bool] = [:]
        for data in snapshot.childSnapshot(forPath: "users").children.allObjects as! [DataSnapshot] {
            tempUsers[data.value as! String] = true
        }
        self.users = tempUsers
        self.recruitingDate = value["recruitingDate"] as! String
        
        self.status = getStatus()
        print(self.status)
    }
    
    
    
    //MARK: TODO - 수정할 것
    private func getStatus() -> CampaignStatus {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
        let dateStr = dateFormatter.string(from: Date())
        if dateStr < recruitingDate {
            return .unOpened
        } else if dateStr < selectionDate {
            return .applied
        } else if dateStr < itemDate {
            return .delivering
        } else if dateStr < uploadDate {
            return .uploading
        } else {
            return .done
        }
        
    }
    
}

struct ItemModel: Codable {
    let name: String
    let description: String
    let price: Int
    let option: ItemOptionModel?
    
    init(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        name = value["name"] as! String
        description = value["description"] as! String
        price = value["price"] as! Int
        
        let optionValue = snapshot.childSnapshot(forPath: "option")
        if optionValue.exists() {
            option = ItemOptionModel(snapshot: optionValue)
        } else {
            option = nil
        }
    }
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

struct ItemOptionModel: Codable {
    let size: [String]
    let color: [String]
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        size = value["size"] as? [String] ?? []
        color = value["color"] as? [String] ?? []
    }
}
