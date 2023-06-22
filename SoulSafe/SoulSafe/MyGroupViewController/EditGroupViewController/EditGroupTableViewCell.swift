//
//  EditGroupTableViewCell.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/18.
//

import UIKit

class EditGroupTBCell: UITableViewCell {
    lazy var baseGroupView = UIView()
    lazy var baseGroupLabel = UILabel()
    lazy var groupView = UIView()
    lazy var groupLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(baseGroupView)
        [baseGroupLabel, groupView].forEach { baseGroupView.addSubview($0) }
        groupView.addSubview(groupLabel)
        
        baseGroupView = Blur.shared.setViewShadowLess(baseGroupView)
        baseGroupView.backgroundColor = UIColor(hex: CIC.shared.M1)
        
        baseGroupLabel.text = "+ 新增群組"
        baseGroupLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        baseGroupLabel.textColor = UIColor.white
        
        groupView.backgroundColor = UIColor(hex: CIC.shared.M3)
        
        groupLabel.textColor = UIColor.white
    }
    
    func setupConstraints() {
        [baseGroupView, baseGroupLabel, groupView, groupLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            baseGroupView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            baseGroupView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            baseGroupView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            baseGroupView.bottomAnchor.constraint(equalTo: bottomAnchor),
            baseGroupView.heightAnchor.constraint(equalToConstant: 58),
            
            baseGroupLabel.leadingAnchor.constraint(equalTo: baseGroupView.leadingAnchor, constant: 16),
            baseGroupLabel.topAnchor.constraint(equalTo: baseGroupView.topAnchor),
            baseGroupLabel.bottomAnchor.constraint(equalTo: baseGroupView.bottomAnchor),
            
            groupView.topAnchor.constraint(equalTo: baseGroupView.topAnchor, constant: 4),
            groupView.leadingAnchor.constraint(equalTo: baseGroupView.leadingAnchor, constant: 4),
            groupView.trailingAnchor.constraint(equalTo: baseGroupView.trailingAnchor, constant: -4),
            groupView.bottomAnchor.constraint(equalTo: baseGroupView.bottomAnchor, constant: -4),
            
            groupLabel.leadingAnchor.constraint(equalTo: groupView.leadingAnchor, constant: 12),
            groupLabel.topAnchor.constraint(equalTo: groupView.topAnchor),
            groupLabel.bottomAnchor.constraint(equalTo: groupView.bottomAnchor)
        ])
    }
}
