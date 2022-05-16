//
//  Styles.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/16.
//

import Foundation

enum Style: String, CaseIterable {
    
    static var allCases: [Style] {
        return [.simple, .lovely, .comfortable, .splendid, .casual, .bubbly, .cute, .gorgious, .sexy]
    }
    
    case simple = "심플"
    case lovely = "러블리"
    case comfortable = "편한"
    case splendid = "화려한"
    case casual = "캐쥬얼한"
    case bubbly = "발랄한"
    case cute = "귀여운"
    case gorgious = "고급스러운"
    case sexy = "섹시한"
}
