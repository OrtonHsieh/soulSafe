//
//  FriendsAnnotationView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/4.
//

import UIKit
import MapKit

class FriendsAnnotationView: MKAnnotationView {
    // 這邊若是 Annotation 是來自於朋友則要使用的 DequeueReuseableAnnotation
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        // 自定圖片
        let image = UIImage(named: "icon-return")
        self.image = image
    }
}
