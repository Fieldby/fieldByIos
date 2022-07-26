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


enum IGMediaType: String, Codable {
    case image = "IMAGE"
    case album = "CAROUSEL_ALBUM"
    case video = "VIDEO"
}

// MARK: - IGMediaModel
struct IGMediaArrayModel: Codable {
    let data: [IGMediaModel]
    let paging: Paging
}

// MARK: - Datum
struct IGMediaModel: Codable {
    let mediaType: IGMediaType
    let mediaURL: String
    let thumbnailURL: String?
    let id: String

    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaURL = "media_url"
        case thumbnailURL = "thumbnail_url"
        case id
    }
}

// MARK: - Paging
struct Paging: Codable {
    let cursors: Cursors
    let next: String?
}

// MARK: - Cursors
struct Cursors: Codable {
    let before, after: String
}
