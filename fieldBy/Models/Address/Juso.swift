//
//  Juso.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/03.
//

import Firebase

struct JusoResponse: Codable {
    var results: JusoResults!
}

struct JusoResults: Codable {
    var common: Common!
    var juso: [Juso]!
}

struct Common: Codable {
    var errorCode: String!
    var currentPage: String!
    var totalCount: String!
    var errorMessage: String!
}

struct Juso: Codable {
    var roadAddr: String!
    var jibunAddr: String!
    var zipNo: String!
    var detail: String?
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        if let roadAddr = value["roadAddr"] as? String,
           let jibunAddr = value["jibunAddr"] as? String,
           let zipNo = value["zipNo"] as? String {
            self.roadAddr = roadAddr
            self.jibunAddr = jibunAddr
            self.zipNo = zipNo
        } else {
            return nil
        }
        self.detail = value["detail"] as? String
    }
}
