//
//  FriendsAnnotation.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/4.
//

import UIKit
import MapKit

class FriendsAnnotation: MKPointAnnotation {
    // 這邊要用來判斷是自己的 Annotation 還是朋友的
    func setupAnnotation(_ annotationTitle: String, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        title = annotationTitle
        coordinate = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
