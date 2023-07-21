//
//  UserAnnotationView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/21.
//

import UIKit
import MapKit

class UserAnnotationView: MKAnnotationView {
    // 這邊若是 Annotation 是來自於朋友則要使用的 DequeueReuseableAnnotation
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
        setupView()
    }
    
    private func configure() {
        // 自定圖片
        let image = UIImage(named: "defaultAvatar")
        self.image = image
    }
    
    private func setupView() {
        frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    }
}
