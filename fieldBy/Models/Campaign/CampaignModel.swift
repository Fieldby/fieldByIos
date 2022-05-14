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
    
    
    init(url: String, brandName: String, isNew: Bool) {
        self.url = url
        self.brandName = brandName
        self.isNew = isNew
    }
}
