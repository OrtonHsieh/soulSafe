//
//  Extension - UIImageView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/6.
//

import UIKit

extension UIImageView {
    func applyCircularMask() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
    }
}
