//
//  CampaignStatus.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/25.
//

import Foundation

enum CampaignStatus: String, Codable {
    case unOpened
    case applied
    case delivering
    case uploading
    case maintaining
    case done
}
