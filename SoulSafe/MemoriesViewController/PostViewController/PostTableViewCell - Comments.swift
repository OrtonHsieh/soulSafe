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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = UIImage(named: "defaultAvatar")
    }
    
    func setupView() {
        basicList.forEach { addSubview($0) }
        commentLabel.numberOfLines = 0
        commentLabel.textColor = .white
    }
    
    func setupConstraints() {
        basicList.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            commentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            commentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            commentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 44),
            commentLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            avatarView.topAnchor.constraint(equalTo: commentLabel.topAnchor, constant: 1),
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarView.heightAnchor.constraint(equalToConstant: 20),
            avatarView.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
}
