//
//  TokenModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/23.
//

import Foundation

struct TokenModel: Codable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
    
    
}
