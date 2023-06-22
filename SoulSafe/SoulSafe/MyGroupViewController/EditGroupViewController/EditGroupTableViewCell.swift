//
//  EditGroupTableViewCell.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/18.
//

import UIKit

protocol EditGroupTBCellDelegate: AnyObject {
    func didPressGroupView(_ cell: EditGroupTBCell, view: UIView)
    func didPressBaseGroupView(_ cell: EditGroupTBCell, view: UIView)
}

class EditGroupTBCell: UITableViewCell {
    lazy var baseGroupView = UIView()
    lazy var baseGroupLabel = UILabel()
    lazy var groupView = UIView()
    lazy var groupLabel = UILabel()
    weak var delegate: EditGroupTBCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        contentView.addSubview(baseGroupView)
        [baseGroupLabel, groupView].forEach { baseGroupView.addSubview($0) }
        groupView.addSubview(groupLabel)
        
        baseGroupView = Blur.shared.setViewShadowLess(baseGroupView)
        baseGroupView.backgroundColor = UIColor(hex: CIC.shared.M1)
        let tapBaseView = UITapGestureRecognizer(target: self, action: #selector(didPressBaseGroupView))
        baseGroupView.addGestureRecognizer(tapBaseView)
        
        baseGroupLabel.text = "+ 新增群組"
        baseGroupLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        baseGroupLabel.textColor = UIColor.white
        
        groupView.backgroundColor = UIColor(hex: CIC.shared.M3)
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(didPressGroupView))
        groupView.addGestureRecognizer(tapView)
        
        groupLabel.textColor = UIColor.white
    }
    
    func setupConstraints() {
        [baseGroupView, baseGroupLabel, groupView, groupLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            baseGroupView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            baseGroupView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            baseGroupView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            baseGroupView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
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
    
    @objc func didPressGroupView() {
        Vibration.shared.lightV()
        delegate?.didPressGroupView(self, view: groupView)
    }
    
    @objc func didPressBaseGroupView() {
        Vibration.shared.lightV()
        delegate?.didPressBaseGroupView(self, view: baseGroupView)
    }
}
