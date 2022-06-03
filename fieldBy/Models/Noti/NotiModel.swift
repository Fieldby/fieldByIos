//
//  NotiModel.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/27.
//

import FirebaseDatabase

class NotiModel: Codable {
    let type: NotiType
    let uuid: String
    let checked: Bool
    let time: String
    
    init?(snapshot: DataSnapshot) {
        let value = snapshot.value as! [String: Any]
        self.uuid = snapshot.key
        if let type = NotiType(rawValue: (value["type"] as? String)!),
           let checked = value["checked"] as? Bool,
           let time = value["time"] as? String {
            self.type = type
            self.checked = checked
            self.time = time
        } else {
            return nil
        }
        

    }

}

enum NotiType: String, Codable {
    case instagram
}
