//
//  String+.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/17.
//

import Foundation

extension String {
    var year: String {
        return split(separator: "-")[0].map{String($0)}.joined()
    }
    
    var month: String {
        return split(separator: "-")[1].map{String($0)}.joined()
    }
    
    var day: String {
        return split(separator: "-")[2].map{String($0)}.joined()
    }
    
    var parsedDate: String {
        return "\(month).\(day)"
    }
    
}
