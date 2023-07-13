//
//  FriendsAnnotation.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/4.
//

import UIKit
import MapKit
import FirebaseFirestore

class FriendsAnnotation: NSObject, MKAnnotation {
    // 這邊要用來判斷是自己的 Annotation 還是朋友的
    var groupID: String
    var userID: String
    var userName: String
    var userAvatar: String
    var lastUpdate: Timestamp
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(userID: String, groupID: String, userName: String, userAvatar: String, coordinate: CLLocationCoordinate2D, lastUpdate: Timestamp) {
        self.groupID = groupID
        self.userID = userID
        self.userName = userName
        self.userAvatar = userAvatar
        self.coordinate = coordinate
        self.lastUpdate = lastUpdate
    }
}
