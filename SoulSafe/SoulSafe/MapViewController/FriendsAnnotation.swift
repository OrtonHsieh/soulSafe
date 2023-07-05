//
//  FriendsAnnotation.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/4.
//

import UIKit
import MapKit

class FriendsAnnotation: NSObject, MKAnnotation {
    // 這邊要用來判斷是自己的 Annotation 還是朋友的
    var userID: String
    var userName: String
    var userAvatar: String
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(userID: String, userName: String, userAvatar: String, coordinate: CLLocationCoordinate2D) {
        self.userID = userID
        self.userName = userName
        self.userAvatar = userAvatar
        self.coordinate = coordinate
    }
}
