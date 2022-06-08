//
//  Media.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/26.
//

import Foundation

// MARK: - MediaData
struct MediaData: Codable {
    let media: Media
}

// MARK: - Media
struct Media: Codable {
    let data: [MediaId]
}

// MARK: - Datum
struct MediaId: Codable {
    let id: String
}

struct ImageData: Codable {
    let id: String
    let mediaURL: String
    let timestamp: String
    let mediaType: IGMediaType

    enum CodingKeys: String, CodingKey {
        case mediaURL = "media_url"
        case timestamp
        case id
        case mediaType = "media_type"
    }
}

// MARK: - MediaData
struct ChildrenData: Codable {
    let children: Children
}

// MARK: - Children
struct Children: Codable {
    let data: [ChildId]
}

// MARK: - Datum
struct ChildId: Codable {
    let id: String
}

enum IGMediaType: String, Codable {
    case image = "IMAGE"
    case album = "CAROUSEL_ALBUM"
    case video = "VIDEO"
}
