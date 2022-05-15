//
//  RoundingCell.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/15.
//

import Foundation
import UIKit

class RoundingCell: UITableViewCell {
    static let reuseId = "roundingCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mainLabel: UILabel!
    
    override func awakeFromNib() {
        containerView.layer.cornerRadius = 13
    }
    
    func selected() {
        mainLabel.textColor = .white
        containerView.backgroundColor = .main
    }
    
    func deselect() {
        mainLabel.textColor = UIColor(red: 48, green: 48, blue: 48)
        containerView.backgroundColor = .fieldByGray
    }
}
