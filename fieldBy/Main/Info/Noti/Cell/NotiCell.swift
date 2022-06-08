//
//  NotiCell.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/27.
//

import Foundation
import UIKit

class NotiCell: UITableViewCell {
    static let reuseId = "notiCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    func bind(notiModel: NotiModel) {
        
        switch notiModel.type {
        case .instagram:
            titleLabel.text = "🎉 인스타그램 연동이 완료되었습니다!"
            contentLabel.text = "원하시는 협찬에 참여하실 수 있게 되었어요! 다양하고 트렌디한 협찬들을 확인하세요."
            
            timeLabel.text = notiModel.time.parseKoreanDateTime
            
        }
        
        
        
        
        
    }
}
