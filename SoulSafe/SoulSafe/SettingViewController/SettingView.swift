//
//  SettingView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/6.
//

import UIKit

class SettingView: UIView {
    lazy var avatarImgView = UIImageView()
    private lazy var userNameLabel = UILabel()
    lazy var generalLabel = UILabel()
    private lazy var settingViewBackBtn = UIButton()
    private lazy var settingViewEditBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [avatarImgView, userNameLabel, generalLabel, settingViewBackBtn, settingViewEditBtn].forEach { addSubview($0) }
        
        settingViewBackBtn.setImage(UIImage(named: "icon-bigBack-toLeft"), for: .normal)
        settingViewBackBtn.addTarget(self, action: #selector(didPressSettingViewBackBtn), for: .touchUpInside)
        
        avatarImgView.image = UIImage(named: "avatar-1")
        avatarImgView.contentMode = .scaleAspectFill
        avatarImgView.clipsToBounds = true
        
        userNameLabel.text = "編輯我的名稱"
        userNameLabel.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        userNameLabel.textColor = .white
        
        generalLabel.text = "一般"
        generalLabel.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        generalLabel.textColor = UIColor(hex: CIC.shared.F1)
        
        settingViewEditBtn.setTitle("編輯", for: .normal)
        settingViewEditBtn.setTitleColor(UIColor(hex: CIC.shared.F1), for: .normal)
    }
    
    private func setupConstraints() {
        [avatarImgView, userNameLabel, generalLabel, settingViewBackBtn, settingViewEditBtn].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            settingViewBackBtn.topAnchor.constraint(equalTo: topAnchor),
            settingViewBackBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            settingViewBackBtn.widthAnchor.constraint(equalToConstant: 36),
            settingViewBackBtn.heightAnchor.constraint(equalToConstant: 36),
            
            settingViewEditBtn.centerYAnchor.constraint(equalTo: settingViewBackBtn.centerYAnchor),
            settingViewEditBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            avatarImgView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImgView.widthAnchor.constraint(equalToConstant: 108),
            avatarImgView.heightAnchor.constraint(equalToConstant: 108),
            avatarImgView.topAnchor.constraint(equalTo: topAnchor, constant: 56),
            
            userNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            userNameLabel.topAnchor.constraint(equalTo: avatarImgView.bottomAnchor, constant: 16),
            
            generalLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            generalLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 16)
        ])
    }
    
    @objc func didPressSettingViewBackBtn() {
        print("返回主頁")
    }
}
