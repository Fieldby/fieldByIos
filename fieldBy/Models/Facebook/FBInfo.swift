//
//  FBInfo.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/17.
//

import FirebaseDatabase

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
    let igModel: IGId

    enum CodingKeys: String, CodingKey {
        case igModel = "instagram_business_account"
    }
}

struct IGId: Codable {
    let id: String
}

// MARK: - InstagramBusinessAccount
struct IGModel: Codable {
    let id: String
    let username: String
    let name: String
    let followers: Int
    let profileUrl: String?
    var token: String?
    
    init(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        id = value["id"] as! String
        username = value["username"] as! String
        name = value["name"] as! String
        followers = value["followers"] as! Int
        profileUrl = value["profileUrl"] as? String
        if let token = value["token"] as? String {
            
            _ = InstagramManager.shared.getLongToken(token: token)
                .subscribe { token in
                    AuthManager.shared.refreshToken(token: token)

                } onError: { err in
                    print(err)
                }

        } 
    }
    
    enum CodingKeys: String, CodingKey {
        case id, username, name
        case followers = "followers_count"
        case profileUrl = "profile_picture_url"
    }
    
}
