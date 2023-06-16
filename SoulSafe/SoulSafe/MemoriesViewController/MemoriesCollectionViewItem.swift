//
//  MemoriesCollectionViewItem.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/16.
//

import UIKit

class MemoriesCVI: UICollectionViewCell {
    lazy var memoryImgView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        contentView.addSubview(memoryImgView)
    }
    
    func setupConstraints() {
        memoryImgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            memoryImgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            memoryImgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            memoryImgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            memoryImgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
