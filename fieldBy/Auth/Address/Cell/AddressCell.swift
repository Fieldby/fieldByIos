//
//  AddressCell.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/03.
//

import UIKit

class AddressCell: UITableViewCell {
    static let reuseId = "addressCell"
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var roadLabel: UILabel!
    @IBOutlet weak var oldLabel: UILabel!
    
    @IBOutlet weak var roadView: UIView!
    @IBOutlet weak var oldView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        [roadView, oldView].forEach { $0!.layer.cornerRadius = 9.5 }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(juso: Juso) {
        numberLabel.text = juso.zipNo
        roadLabel.text = juso.roadAddr
        oldLabel.text = juso.jibunAddr
    }

}
