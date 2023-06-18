//
//  EditGroupTableViewCell.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/18.
//

import UIKit

class EditGroupTBCell: UITableViewCell {
    let groupView = UIView()
    let groupTitleLabel = UILabel()
    let separatorView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(groupView)
        [groupTitleLabel, separatorView].forEach { addSubview($0) }
        
        groupView.backgroundColor = .clear
        
        groupTitleLabel.textColor = .white
        
        separatorView.backgroundColor = UIColor(hex: CIC.shared.M2)
    }
    
    func setupConstraints() {
        [groupView, groupTitleLabel, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            groupView.topAnchor.constraint(equalTo: topAnchor),
            groupView.leadingAnchor.constraint(equalTo: leadingAnchor),
            groupView.trailingAnchor.constraint(equalTo: trailingAnchor),
            groupView.heightAnchor.constraint(equalToConstant: 54),
            
            groupTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            groupTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            separatorView.topAnchor.constraint(equalTo: groupView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 3),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
