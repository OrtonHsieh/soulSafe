//
//  GroupSelectionStackView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/29.
//

import UIKit

class GroupSelectionStackView: UIStackView {
    weak var delegate: GroupSelectionStackViewDelegate?
    weak var dataSource: GroupSelectionStackViewDataSource? {
        didSet {
            setupButtons()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStackView() {
        axis = .horizontal // 設定水平方向排列
        alignment = .center
        distribution = .fillEqually // 按鈕平均佈局
        spacing = 10 // 設定按鈕之間的間距
    }
    
    func setupButtons() {
        clearButtons()
        guard let dataSource = dataSource else { print("失敗"); return }
        let numberOfButtons = dataSource.numberOfButtons(in: self)
        
        for i in 0..<numberOfButtons {
            let button = UIButton()
            button.tag = i
            button.addTarget(self, action: #selector(didSelectGroup), for: .touchUpInside)
            button.setTitle(dataSource.titleForButtons(at: i, in: self), for: .normal)
            button.setTitleColor(dataSource.buttonTextColor(in: self), for: .normal)
            button.titleLabel?.font = dataSource.buttonTextFont(in: self)
            button.backgroundColor = dataSource.buttonBackgroundColor(in: self)
            button.layer.borderWidth = 0
            button.layer.borderColor = dataSource.buttonBorderColor(in: self)
            button.layer.cornerRadius = 8
            addArrangedSubview(button)
        }
    }
    
    @objc func didSelectGroup(_ button: UIButton) {
        delegate?.groupSelectionStackView(self, didSelectButton: button)
    }
    
    func clearButtons() {
        for subview in arrangedSubviews {
            subview.removeFromSuperview()
        }
    }
}
