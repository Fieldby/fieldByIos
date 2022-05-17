//
//  Dictionary+.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/17.
//

import Foundation

extension Dictionary {
    var JSON: Data {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch {
            return Data()
        }
    }
}
