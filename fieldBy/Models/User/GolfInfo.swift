//
//  GolfInfo.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/15.
//

import Foundation

enum StrokeAverage: String, CaseIterable {
    static var allCases: [StrokeAverage] {
        return [.under, .even, .single, .eighty, .ninety, .hundred, .hundredTen, .hundredTwenty]
    }
    
    case under = "언더"
    case even = "이븐"
    case single = "싱글"
    case eighty = "평균 80타"
    case ninety = "평균 90타"
    case hundred = "평균 100타"
    case hundredTen = "평균 110타"
    case hundredTwenty = "평균 120타"
}

enum Career: String, CaseIterable {
    static var allCases: [Career] {
        return [.belowOne, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .overTen]
    }
    
    case belowOne = "1년 미만"
    case one = "1년"
    case two = "2년"
    case three = "3년"
    case four = "4년"
    case five = "5년"
    case six = "6년"
    case seven = "7년"
    case eight = "8년"
    case nine = "9년"
    case overTen = "10년 이상"
}

enum RoundingCount: String, CaseIterable {
    
    static var allCases: [RoundingCount] {
        return [.oneOrTwo, .threeOrFour, .fiveOrSix, .sevenOrEight, .nineOrTen, .overTen]
    }
    
    case oneOrTwo = "1~2회"
    case threeOrFour = "3~4회"
    case fiveOrSix = "5~6회"
    case sevenOrEight = "7~8회"
    case nineOrTen = "9~10회"
    case overTen = "10회 이상"
}

