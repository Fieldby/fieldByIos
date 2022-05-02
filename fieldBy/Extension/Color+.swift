//
//  Color+.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/01.
//

import Foundation
import UIKit

extension UIColor {
    class var main: UIColor {
        return UIColor(named: "MainColor")!
    }
    
    class var fieldByGray: UIColor {
        return UIColor(named: "LightGray")!
    }
}

extension UIColor {

    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
    convenience init(red: Double, green: Double, blue: Double, a: Double = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
    convenience init(rgb: Int) {
           self.init(
               red: (rgb >> 16) & 0xFF,
               green: (rgb >> 8) & 0xFF,
               blue: rgb & 0xFF
           )
       }
    convenience init(argb: Int) {
        self.init(
            red: (argb >> 16) & 0xFF,
            green: (argb >> 8) & 0xFF,
            blue: argb & 0xFF,
            a: (argb >> 24) & 0xFF
        )
    }
    convenience init?(hexString: String) {
            var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
            switch chars.count {
            case 3: chars = chars.flatMap { [$0, $0] }; fallthrough
            case 6: chars = ["F","F"] + chars
            case 8: break
            default: return nil
            }
            self.init(red: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                    green: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                     blue: .init(strtoul(String(chars[6...7]), nil, 16)) / 255,
                    alpha: .init(strtoul(String(chars[0...1]), nil, 16)) / 255)
        }
}
