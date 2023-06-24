//
//  PostTableViewCell - List.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/17.
//

import UIKit

class PostTBCellList: UITableViewCell {
    lazy var groupView: UIView = {
        let groupView = UIView()
        groupView.frame = CGRect(x: 16, y: 12, width: 120, height: 36)
        groupView.layer.borderWidth = 1
        groupView.layer.borderColor = UIColor(hex: CIC.shared.F2).cgColor
        groupView.backgroundColor = UIColor(hex: CIC.shared.M3)
        groupView.layer.cornerRadius = 15
        let groupLabel = UILabel()
        groupLabel.text = "選擇留言串"
        groupLabel.frame = CGRect(x: 11, y: 6, width: groupView.frame.width - 22, height: groupView.frame.height - 12)
        groupLabel.font = .systemFont(ofSize: 16, weight: .medium)
        groupView.addSubview(groupLabel)
        return groupView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(groupView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
