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
    
    override func awakeFromNib() {
        mainImageView.layer.cornerRadius = 7
    }
    
    func bind(notiModel: NotiModel) {
        NotiManager.shared.read(notiUid: notiModel.uuid)
        timeLabel.text = notiModel.time.parseKoreanDateTime
        
        switch notiModel.type {
        case .instagram:
            titleLabel.text = "🎉 인스타그램 연동이 완료되었습니다!"
            contentLabel.text = "원하시는 협찬에 참여하실 수 있게 되었어요! 다양하고 트렌디한 협찬들을 확인하세요."
            
        case .campaignApplied:
            contentLabel.text = "제안이 성사되면 알려드릴게요."
            if let url = notiModel.url {
                mainImageView.setImage(url: url)
            }
            
            if let title = notiModel.title {
                titleLabel.text = "👍🏻 캠페인 \(title)의 제안이 완료되었습니다!"

            }
            
        }
        
    }
}
