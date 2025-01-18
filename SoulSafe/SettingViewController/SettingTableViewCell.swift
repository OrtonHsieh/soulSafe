//
//  SettingTableViewCell.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/6.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    lazy var settingOptionLabel = UILabel()
    private lazy var settingOptionView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        settingOptionView.layer.cornerRadius = 12
        clipsToBounds = false
    }
    
    private func setupView() {
        addSubview(settingOptionView)
        settingOptionView.addSubview(settingOptionLabel)
        
        settingOptionLabel.textColor = .white
        
        settingOptionView.backgroundColor = UIColor(hex: CIC.shared.M1)
    }
    
    private func setupConstraints() {
        [settingOptionView, settingOptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            settingOptionView.topAnchor.constraint(equalTo: topAnchor),
            settingOptionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            settingOptionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            settingOptionView.heightAnchor.constraint(equalToConstant: 54),
            settingOptionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            settingOptionLabel.leadingAnchor.constraint(equalTo: settingOptionView.leadingAnchor, constant: 12),
            settingOptionLabel.centerYAnchor.constraint(equalTo: settingOptionView.centerYAnchor)
        ])
    }
}
