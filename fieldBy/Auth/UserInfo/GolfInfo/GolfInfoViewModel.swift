//
//  GolfInfoViewModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/15.
//

import Foundation

class GolfInfoViewModel: NSObject {
    var strokeIndex: Int?
    var careerIndex: Int?
    var roundingIndex: Int?
    
    var pushIsProVC: (() -> Void)!
    
    func saveInfo() {
        AuthManager.saveUserInfo(key: "stroke", value: StrokeAverage.allCases[strokeIndex!].rawValue)
        AuthManager.saveUserInfo(key: "career", value: Career.allCases[careerIndex!].rawValue)
        AuthManager.saveUserInfo(key: "roundingFrequency", value: RoundingCount.allCases[roundingIndex!].rawValue)
    }
}
