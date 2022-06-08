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
            if let url = notiModel.url {
                mainImageView.setImage(url: url)
            }
            
            if let title = notiModel.title {
                titleLabel.text = "👍🏻 '\(title)' 캠페인 신청 완료!"
                contentLabel.text = "'\(title)'캠페인을 신청하셨습니다!"

            }
            
        case .campaignSelected:
            if let url = notiModel.url {
                mainImageView.setImage(url: url)
            }
            
            if let title = notiModel.title {
                titleLabel.text = "🎉 '\(title)' 캠페인에 선정되었습니다!"
                contentLabel.text = "'\(title)' 캠페인에 선정되었습니다. 가이드라인을 확인해보세요!"

            }
        case .campaignOpened:
            if let url = notiModel.url {
                mainImageView.setImage(url: url)
            }
            
            if let title = notiModel.title {
                titleLabel.text = "👍🏻 '\(title)' 캠페인 오픈!"
                contentLabel.text = "'\(title)'캠페인을 오픈했습니다. 지금 확인해보세요!"

            }
        case .itemDelivered:
            if let url = notiModel.url {
                mainImageView.setImage(url: url)
            }
            
            if let title = notiModel.title {
                titleLabel.text = "🚛 '\(title)' 캠페인 상품 발송!"
                contentLabel.text = "'\(title)' 캠페인 상품이 발송되었습니다!"
            }
        case .uploadFeed:
            if let url = notiModel.url {
                mainImageView.setImage(url: url)
            }
            
            if let title = notiModel.title {
                titleLabel.text = "🚛 '\(title)' 캠페인을 업로드 해주세요!"
                contentLabel.text = "'\(title)' 캠페인 업로드 기간입니다. 가이드에 맞춰 업로드 해주세요!"
            }
        }
        
    }
}
