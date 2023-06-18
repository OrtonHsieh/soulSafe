//
//  MyGroupTBCell.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/18.
//

import UIKit

class GroupTBCell: UITableViewCell {
    lazy var groupView = UIView()
    lazy var groupLabel = UILabel()
    lazy var list = [groupView, groupLabel]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        groupView.layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        list.forEach { addSubview($0) }
        
        groupView.backgroundColor = UIColor(hex: CIC.shared.M2)
    }
    
    func setupConstraints() {
        list.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            groupView.topAnchor.constraint(equalTo: topAnchor),
            groupView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            groupView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            groupView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            groupView.heightAnchor.constraint(equalToConstant: 54),
            
            groupLabel.leadingAnchor.constraint(equalTo: groupView.leadingAnchor, constant: 12),
            groupLabel.centerYAnchor.constraint(equalTo: groupView.centerYAnchor)
        ])
    }
}
