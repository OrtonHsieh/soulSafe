//
//  LocationModel.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/4.
//

import UIKit

struct Location: Codable {
    var id: String
    var userID: String
    var userName: String
    var userLocation: [String]
    var userAvatar: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case userName
        case userLocation
        case userAvatar
    }
    
    var toDict: [String: Any] {
        return [
            "id": id as Any,
            "userID": userID as Any,
            "userName": userName as Any,
            "userLocation": userLocation as Any,
            "userAvatar": userAvatar as Any
        ]
    }
}
