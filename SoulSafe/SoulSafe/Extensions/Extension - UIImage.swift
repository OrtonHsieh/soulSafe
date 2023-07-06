//
//  Extension - UIImage.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/6.
//

import UIKit

extension UIImage {
    func resizedImage(with size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return resizedImage
    }
}
