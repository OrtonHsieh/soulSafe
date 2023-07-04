//
//  UserAnnotation.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/4.
//

import UIKit
import MapKit

class UserAnnotation: MKPointAnnotation {
    override var coordinate: CLLocationCoordinate2D {
        didSet {
            // Notify the map view that the annotation's coordinate has been updated
            NotificationCenter.default.post(name: NSNotification.Name("AnnotationCoordinateUpdated"), object: self)
        }
    }
}
