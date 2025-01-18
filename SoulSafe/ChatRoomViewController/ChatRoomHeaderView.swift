//
//  ChatRoomCloseView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/26.
//

import UIKit

protocol ChatRoomHeaderViewDelegate: AnyObject {
    func didPressCloseBtn(_ viewController: ChatRoomHeaderView, button: UIButton)
}

class ChatRoomHeaderView: UIView {
    lazy var closeBtn = UIButton()
    lazy var groupTitleLabel = UILabel()
    weak var delegate: ChatRoomHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        [closeBtn, groupTitleLabel].forEach { addSubview($0) }
        let symbolSize: CGFloat = 30
        closeBtn.setImage(
            UIImage(systemName: "xmark.circle"
        )?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: symbolSize)
        ), for: .normal)
        closeBtn.addTarget(self, action: #selector(didPressCloseBtn), for: .touchUpInside)
        closeBtn.tintColor = UIColor(hex: CIC.shared.F2)
        
        groupTitleLabel.layer.borderWidth = 1
        groupTitleLabel.layer.borderColor = UIColor(hex: CIC.shared.F2).cgColor
        groupTitleLabel.clipsToBounds = true
        groupTitleLabel.backgroundColor = UIColor(hex: CIC.shared.M2)
        groupTitleLabel.textColor = UIColor(hex: CIC.shared.F1)
        groupTitleLabel.textAlignment = .center
    }
    
    func setupConstraints() {
        [closeBtn, groupTitleLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            closeBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            closeBtn.heightAnchor.constraint(equalToConstant: 32),
            closeBtn.widthAnchor.constraint(equalToConstant: 32),
            
            groupTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            groupTitleLabel.centerYAnchor.constraint(equalTo: closeBtn.centerYAnchor),
            groupTitleLabel.widthAnchor.constraint(equalToConstant: 100),
            groupTitleLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc func didPressCloseBtn() {
        Vibration.shared.mediumV()
        delegate?.didPressCloseBtn(self, button: closeBtn)
    }
}
