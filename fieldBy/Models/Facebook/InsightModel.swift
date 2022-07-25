//
//  InsightModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/07/10.
//

import Foundation

// MARK: - InsightModel
struct InsightModel: Codable {

    
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Codable {
    let name, period: String
    let values: [Value]
    let title, datumDescription, id: String

    enum CodingKeys: String, CodingKey {
        case name, period, values, title
        case datumDescription = "description"
        case id
    }
}

// MARK: - CountsModel
struct CountsModel: Codable {
    let likeCount, commentsCount: Int

    enum CodingKeys: String, CodingKey {
        case likeCount = "like_count"
        case commentsCount = "comments_count"
    }
}

// MARK: - Days28Model
struct Days28Model: Codable {
    let data: [Datum]
}


// MARK: - Value
struct Value: Codable {
    let value: Int
    let endTime: String?

    enum CodingKeys: String, CodingKey {
        case value
        case endTime = "end_time"
    }
}

