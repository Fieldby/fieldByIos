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
    let title: String
    
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
    var priority = 0
    
    var users: [String: Bool]
    
    var status: CampaignStatus = .unOpened
    
    
    
    init(url: String, brandUuid: String, isNew: Bool, itemModel: ItemModel, dueDate: String, selectionDate: String, itemDate: String, uploadDate: String, leastFeed: Int, maintain: Int, brandName: String, guides: [GuideModel], uuid: String, brandInstagram: String, hashTagModel: HashTagModel, users: [String: Bool], recruitingDate: String, status: CampaignStatus, title: String) {
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
        self.title = title
    }
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        
        self.uuid = snapshot.key
        
        if let imageUrl = value["mainImageUrl"] as? String,
           let brandUuid = value["brandUuid"] as? String,
           let isNew = value["isNew"] as? Bool,
           let dueDate = value["dueDate"] as? String,
           let selectionDate = value["selectionDate"] as? String,
           let itemDate = value["itemDate"] as? String,
           let uploadDate = value["uploadDate"] as? String,
           let leastFeed = value["leastFeed"] as? String,
           let maintain = value["maintain"] as? String,
           let brandName = value["brandName"] as? String,
           let brandInstagram = value["brandInstagram"] as? String,
           let recruitingDate = value["recruitingDate"] as? String,
           let title = value["campaignTitle"] as? String
            
        {
            self.title = title
            self.mainImageUrl = "campaignImages/\(self.title)/\(imageUrl)"
            self.brandUuid = brandUuid
            self.isNew = isNew
            self.dueDate = dueDate
            self.selectionDate = selectionDate
            self.itemDate = itemDate
            self.uploadDate = uploadDate
            self.leastFeed = Int(leastFeed)!
            self.maintain = Int(maintain)!
            self.brandName = brandName
            self.brandInstagram = brandInstagram
            self.recruitingDate = recruitingDate
        } else {
            return nil
        }

        if let priority = value["priority"] as? String {
            self.priority = Int(priority) ?? 0
        }
        let itemValue = snapshot.childSnapshot(forPath: "item")
        if !itemValue.exists() { return nil }
        self.itemModel = ItemModel(snapshot: itemValue)
        
        if !snapshot.childSnapshot(forPath: "guides").exists() { return nil }
        var tempGuides = [GuideModel]()
        for data in snapshot.childSnapshot(forPath: "guides").children.allObjects as! [DataSnapshot] {
            let guideModel = GuideModel(snapshot: data)!
            tempGuides.append(guideModel)
        }
        self.guides = tempGuides
        
        if !snapshot.childSnapshot(forPath: "hashTags").exists() { return nil }
        self.hashTagModel = HashTagModel(snapshot: snapshot.childSnapshot(forPath: "hashTags"))!
        
        var tempUsers: [String: Bool] = [:]
        for data in snapshot.childSnapshot(forPath: "users").children.allObjects as! [DataSnapshot] {
            tempUsers[data.value as! String] = true
        }
        self.users = tempUsers        
        self.status = getStatus()
        print(title, status)
    }
    
    
    private func getStatus() -> CampaignStatus {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
        let dateStr = dateFormatter.string(from: Date())
        if dateStr < recruitingDate {
            return .unOpened
        } else if dateStr < "\(selectionDate)-23-59" {
            return .applied
        } else if dateStr < "\(itemDate)-23-59" {
            return .delivering
        } else if dateStr < "\(uploadDate)-23-59" {
            return .uploading
        } else if dateStr < getFinishDate() {
            return .maintaining
        } else if uuid == "-N5EALVGOYpLlZzZqA09" || uuid == "-N5ECdjzaPhLTEydEG6u" {
            return .exception
        } else {
            return .done
        }
        
    }
    
    func getMainImage() -> Single<UIImage> {
        return Single.create() { [unowned self] observable in
            let parsedImageName = String(String(mainImageUrl.split(separator: ".")[0]).split(separator: "/")[2])

            if let image = UIImage(named: parsedImageName) {
                print("yes")
                observable(.success(image))
            } else {
                print("else")
                Storage.storage().reference().child(mainImageUrl)
                    .downloadURL { [unowned self] url, error in
                        if let url = url {
                            let data = try! Data(contentsOf: url)
                            observable(.success(UIImage(data: data)!))
                        } else {
                            observable(.success(UIImage(named: "mainLogo")!))
                        }
                    }
            }
            return Disposables.create()
        }

    }
    
    func getMainImageUrl() -> Single<String> {
        return Single.create() { [unowned self] observable in
            Storage.storage().reference().child(mainImageUrl)
                .downloadURL { url, error in
                    if let url = url {
                        observable(.success(url.absoluteString))
                    }
                }
            return Disposables.create()
        }
    }
    
    func getFinishDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startingDate = dateFormatter.date(from: uploadDate)!
        let finishingDate = Calendar.current.date(byAdding: .day, value: maintain, to: startingDate)!
        
        return dateFormatter.string(from: finishingDate)
    }
    
}

struct ItemModel: Codable {
    let name: String
    let description: String
    let price: Int
    let url: String
    let option: ItemOptionModel?
    
    init(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        name = value["name"] as! String
        description = value["description"] as! String
        price = Int(value["price"] as! String)!
        url = value["url"] as! String
        
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
