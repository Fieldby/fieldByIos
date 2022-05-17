//
//  FBInfo.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/17.
//

import Foundation

struct FBInfo: Codable {
    let name, id: String
}

struct FBPageList: Codable {
    let data: [FBPageInfo]
}

struct FBPageInfo: Codable {
    let name, id: String
}

// MARK: - InstagramData
struct IGData: Codable {
    let instagramBusinessAccount: InstagramBusinessAccount

    enum CodingKeys: String, CodingKey {
        case instagramBusinessAccount = "instagram_business_account"
    }
}

// MARK: - InstagramBusinessAccount
struct InstagramBusinessAccount: Codable {
    let id: String
}
