//
//  PostTableViewCell.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/17.
//

import UIKit

class PostTBCellCmt: UITableViewCell {
    lazy var avatarView = UIImageView()
    lazy var commentLabel = UILabel()
    // 基本框架的 list，用來快速 forEach
    lazy var basicList = [avatarView, commentLabel]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        basicList.forEach { addSubview($0) }
    }
    
    func setupConstraints() {
        basicList.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            avatarView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            avatarView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarView.heightAnchor.constraint(equalToConstant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 16),
            
            commentLabel.topAnchor.constraint(equalTo: avatarView.topAnchor),
            commentLabel.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor),
            commentLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8)
        ])
    }
}
