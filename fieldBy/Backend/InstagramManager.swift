//
//  InstagramManager.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/08.
//

import Alamofire
import RxSwift
import RxCocoa
import NSObject_Rx

class InstagramManager: CommonBackendType {
    static let appId = "681817606228494"
    static let redirectUri = "https://hyuwo.notion.site/a7bb0e42d03142c79d2d3de57dd768b7"
    
    static let token = "IGQVJVZAEVlQVp0eGR6T1l2ZA3Ayem9IdWM5bnFRaFNWZAmwzcEM3c2NRc3pVdmI5UlkzUHpkTVZARWkxoM0RucGlUMGZAIcW00VE5odjdyT0hhTG9LZADc2YXBFenpueTlheXU2R0JqdFNLVWh5VlNpdFZAZAUwZDZD"
    static let longToken = "IGQVJWcXpZALU5udzJZAN3BJUjZAHR1FscFAwd1V1N3JCcVpGajVOX1Q4Tjk4WFVXcVFuRjVnbkNVamJqUGZA1QzRFeHRSQV9YNEtZAR042djgxa0JuTEJzYk5ncGtHM291R1B5MmlnYXNB"
    //https://graph.instagram.com/refresh_access_token
    //?grant_type=ig_refresh_token
    //&access_token={단기토큰}
    
    
//    static func test() {
//        let path = "https://graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token=\(token)"
//
//        AF.request(path, method: .get).responseString { response in
//            switch response.result {
//            case .success(let str):
//                print(str)
//            case .failure(let err):
//                print(err)
//            }
//        }
//
//    }

    
    static func test2() -> Single<InstagramData> {

        return Single.create { observable in
            let url = "https://graph.instagram.com/me/media"
            let params: [String: Any] = ["fields": "id,media_type,media_url,thumbnail_url,username,timestamp",
                                            "access_token": longToken]
            
//            AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default).responseString { response in
//                switch response.result {
//                case .success(let data):
//                    print(data)
//                case .failure(let err):
//                    print(err)
//                }
//            }
            
            AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default).responseData { response in
                switch response.result {
                case .success(let data):

                    
                    let data = try! JSONDecoder().decode(InstagramData.self, from: data)
                    observable(.success(data))

                case .failure(let err):
                    print(err)
                }
            }



            return Disposables.create()
        }







    }
}


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let instagramData = try? newJSONDecoder().decode(InstagramData.self, from: jsonData)

import Foundation

// MARK: - InstagramData
class InstagramData: Codable {
    let data: [Datum]
    let paging: Paging

    init(data: [Datum], paging: Paging) {
        self.data = data
        self.paging = paging
    }
}

// MARK: - Datum
class Datum: Codable {
    let id: String
    let mediaType: MediaType
    let mediaURL: String
    let username: Username
    let timestamp: String

    enum CodingKeys: String, CodingKey {
        case id
        case mediaType = "media_type"
        case mediaURL = "media_url"
        case username, timestamp
    }

    init(id: String, mediaType: MediaType, mediaURL: String, username: Username, timestamp: String) {
        self.id = id
        self.mediaType = mediaType
        self.mediaURL = mediaURL
        self.username = username
        self.timestamp = timestamp
    }
}

enum MediaType: String, Codable {
    case carouselAlbum = "CAROUSEL_ALBUM"
}

enum Username: String, Codable {
    case fieldbyOfficial = "fieldby_official"
}

// MARK: - Paging
class Paging: Codable {
    let cursors: Cursors
    let next: String

    init(cursors: Cursors, next: String) {
        self.cursors = cursors
        self.next = next
    }
}

// MARK: - Cursors
class Cursors: Codable {
    let before, after: String

    init(before: String, after: String) {
        self.before = before
        self.after = after
    }
}
