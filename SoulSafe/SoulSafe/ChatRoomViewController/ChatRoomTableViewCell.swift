//
//  ChatRoomTableView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/26.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {
    lazy var avatarView = UIImageView()
    lazy var msgLabel = UILabel()
    lazy var msgView = UIView()
    // 基本框架的 list，用來快速 forEach
    lazy var basicList = [avatarView, msgView]
    lazy var leadingCons: CGFloat = 44
    lazy var trailingCons: CGFloat = 0
    
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
        msgView.addSubview(msgLabel)
        msgView.backgroundColor = UIColor(hex: CIC.shared.M2)
        msgLabel.numberOfLines = 0
        msgLabel.textColor = .white
    }
    
    func setupConstraints() {
        basicList.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        msgLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            msgView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            msgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingCons),
            msgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            msgView.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            msgLabel.topAnchor.constraint(equalTo: msgView.topAnchor, constant: 8),
            msgLabel.bottomAnchor.constraint(equalTo: msgView.bottomAnchor, constant: -8),
            msgLabel.leadingAnchor.constraint(equalTo: msgView.leadingAnchor, constant: 8),
            msgLabel.trailingAnchor.constraint(equalTo: msgView.trailingAnchor, constant: -8),
            
            avatarView.topAnchor.constraint(equalTo: msgLabel.topAnchor, constant: 1),
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarView.heightAnchor.constraint(equalToConstant: 20),
            avatarView.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
}
