//
//  ChatRoomTableViewCell - Mine.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/27.
//

import UIKit

class ChatRoomTableViewCellMine: UITableViewCell {
    lazy var msgLabel = UILabel()
    lazy var msgView = UIView()
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
        addSubview(msgView)
        msgView.addSubview(msgLabel)
        msgView.backgroundColor = UIColor(hex: CIC.shared.F1)
        msgLabel.numberOfLines = 0
        msgLabel.textColor = .black
        msgLabel.textAlignment = .left
    }
    
    func setupConstraints() {
        [msgView, msgLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            msgView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            msgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            msgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            msgView.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            msgLabel.topAnchor.constraint(equalTo: msgView.topAnchor, constant: 8),
            msgLabel.bottomAnchor.constraint(equalTo: msgView.bottomAnchor, constant: -8),
            msgLabel.trailingAnchor.constraint(equalTo: msgView.trailingAnchor, constant: -8),
            msgLabel.leadingAnchor.constraint(equalTo: msgView.leadingAnchor, constant: 8)
        ])
    }
}
