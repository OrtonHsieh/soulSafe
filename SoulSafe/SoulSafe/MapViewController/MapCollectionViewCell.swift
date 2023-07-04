//
//  MapCollectionViewCell.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/3.
//

import UIKit

class MapCollectionViewCell: UICollectionViewCell {
    // Add any custom UI elements or properties specific to your cell
    private lazy var groupIconInMapCollectionView = UIImageView()
    lazy var groupTitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupCell() {
        // Perform any custom setup for your cell, such as adding subviews or configuring layout
        backgroundColor = UIColor(hex: CIC.shared.M2)
    }
    
    private func setupView() {
        [groupIconInMapCollectionView, groupTitleLabel].forEach { addSubview($0) }
        groupIconInMapCollectionView.image = UIImage(named: "icon-community")
        groupTitleLabel.text = "RealChillSquad"
    }
    
    private func setupConstraints() {
        [groupIconInMapCollectionView, groupTitleLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            groupIconInMapCollectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            groupIconInMapCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            groupIconInMapCollectionView.heightAnchor.constraint(equalToConstant: 36),
            groupIconInMapCollectionView.widthAnchor.constraint(equalToConstant: 36),
            
            groupTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            groupTitleLabel.leadingAnchor.constraint(equalTo: groupIconInMapCollectionView.trailingAnchor, constant: 16)
        ])
    }
}
