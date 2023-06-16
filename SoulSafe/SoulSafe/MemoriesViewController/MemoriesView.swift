//
//  MemoriesView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/16.
//

import UIKit

class MemoriesView: UIView {
    let backButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        [backButton].forEach { addSubview($0) }
        if let image = UIImage(named: "icon-bigBack") {
            let flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .downMirrored)
            backButton.setImage(flippedImage.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        backButton.addTarget(self, action: #selector(buttonDidPress), for: .touchUpInside)
    }
    
    func setupConstraints() {
        [backButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        let spec: CGFloat = 36
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topAnchor),
            backButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            backButton.widthAnchor.constraint(equalToConstant: spec),
            backButton.heightAnchor.constraint(equalToConstant: spec)
        ])
    }
    
    @objc func buttonDidPress() {
        print("滑動回去 mainVC")
    }
}
