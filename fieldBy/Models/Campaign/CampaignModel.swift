//
//  CampaignModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/12.
//

import Foundation

class CampaignModel {
    let url: String
    let brandName: String
    let isNew: Bool
    let item: ItemModel
    
    let dueDate: String
    let selectionDate: String
    let itemDate: String
    let uploadDate: String
    
    let leastFeed: Int
    let maintain: Int
    
    
    init(url: String, brandName: String, isNew: Bool, item: ItemModel, dueDate: String, selectionDate: String, itemDate: String, uploadDate: String, leastFeed: Int, maintain: Int) {
        self.url = url
        self.brandName = brandName
        self.isNew = isNew
        self.item = item
        self.dueDate = dueDate
        self.selectionDate = selectionDate
        self.itemDate = itemDate
        self.uploadDate = uploadDate
        self.leastFeed = leastFeed
        self.maintain = maintain
    }
}

struct ItemModel {
    let name: String
    let description: String
    let price: String
}
