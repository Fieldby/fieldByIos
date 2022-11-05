//
//  PushManager.swift
//  fieldBy
//
//  Created by 박진서 on 2022/06/08.
//

import ObjectMapper
import Alamofire
import Firebase

class PushManager: Mappable {
    static let shared = PushManager()
    
    private init() {}
    
    let url = "https://fcm.googleapis.com/fcm/send"
    
    let header: HTTPHeaders = [
        "Content-Type": "application/json",
        "Authorization": "key=AAAAd3VbcvA:APA91bEE-_bu4E6TERxIVo0_66CjRQbfjIDB7FwiQJakRRv5rWVMK95R58UFCDUAS1l79mXKJQ_SQVwxjDgdST49rB43QJG-zD0Mmv6Zn2r4xJRAlNf5R-ZpJvmel3VWUSVAJK9bxOJO"
    ]
    
    var to: String?
    var notification: Notification = Notification()
    var data: DataModel = DataModel() // For Foreground
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        to <- map["to"]
        notification <- map["notification"]
        data <- map["data"]
    }
    
    class Notification: Mappable{
        var title: String?
        var text: String?
        
        init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            title <- map["title"]
            text <- map["body"]
        }
    }
    
    class DataModel: Mappable {
        var type: String?
        var uuid: String?
        
        init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            type <- map["type"]
            uuid <- map["uuid"]
        }
    }
    
    func commonPush(targetToken: String, notiType: NotiType, _ campaignModel: CampaignModel?) {
        let url = self.url
        let header = self.header
        self.to = targetToken
        
        switch notiType {
        case .instagram:
            break
        case .campaignApplied:
            
            self.notification.title = "👍🏻 '\(campaignModel!.title)' 캠페인 신청 완료!"
            self.notification.text = "'\(campaignModel!.title)'캠페인을 신청하셨습니다!"
            self.data.type = notiType.rawValue
            self.data.uuid = campaignModel!.uuid
        case .campaignSelected:
            break
        case .campaignOpened:
            break
        case .itemDelivered:
            break
        case .uploadFeed:
            break
        }

        let params = self.toJSON()
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseString { responce in
            print(responce)
        }
    }
    
    func solstayPush() {
        let url = self.url
        let header = self.header
    }
}
