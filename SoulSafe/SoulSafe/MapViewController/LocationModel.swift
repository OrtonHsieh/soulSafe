//
//  LocationModel.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/4.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Location: Codable {
    var id: String
    var groupID: String
    var userID: String
    var userName: String
    var userLocation: [String]
    var userAvatar: String
    var lastUpdate: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupID
        case userID
        case userName
        case userLocation
        case userAvatar
        case lastUpdate
    }
    
    var toDict: [String: Any] {
        return [
            "id": id as Any,
            "groupID": groupID as Any,
            "userID": userID as Any,
            "userName": userName as Any,
            "userLocation": userLocation as Any,
            "userAvatar": userAvatar as Any,
            "lastUpdate": lastUpdate as Any
        ]
    }
}
