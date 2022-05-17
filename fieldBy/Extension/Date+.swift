//
//  Date+.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/17.
//

import Foundation

extension Date {
    var day: Int {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "dd"
        return Int(formatter.string(from: self))!
    }
    
    var month: Int {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MM"
        return Int(formatter.string(from: self))!
    }
    
    var year: Int {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy"
        return Int(formatter.string(from: self))!
    }
}
