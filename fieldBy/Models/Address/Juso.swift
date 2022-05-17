//
//  Juso.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/03.
//

import Foundation

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
}
