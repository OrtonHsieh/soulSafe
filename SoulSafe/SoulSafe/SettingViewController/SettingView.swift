//
//  SettingView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/6.
//

import UIKit
import Kingfisher

protocol SettingViewDelegate: AnyObject {
    func didPressSettingViewBackBtn(_ view: SettingView)
    func didPressSettingViewEditBtn(_ view: SettingView)
    func presentImagePicker(_ view: SettingView)
}

class SettingView: UIView {
    weak var delegate: SettingViewDelegate?
    lazy var avatarImgViewContainer = UIView()
    lazy var avatarImgView = UIImageView()
    lazy var userNameLabel = UILabel()
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
        [avatarImgViewContainer, userNameLabel, generalLabel, settingViewBackBtn, settingViewEditBtn].forEach { addSubview($0) }
        avatarImgViewContainer.addSubview(avatarImgView)
        
        settingViewBackBtn.setImage(UIImage(named: "icon-bigBack-toLeft"), for: .normal)
        let symbolSizeForBackBtn: CGFloat = 28
        settingViewBackBtn.setImage(
            UIImage(systemName: "arrowtriangle.backward")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: symbolSizeForBackBtn)),
            for: .normal
        )
        settingViewBackBtn.tintColor = UIColor(hex: CIC.shared.F1)
        settingViewBackBtn.imageView?.contentMode = .scaleAspectFit
        settingViewBackBtn.addTarget(self, action: #selector(didPressSettingViewBackBtn), for: .touchUpInside)
        
        guard let avatarImg = UserDefaults.standard.object(forKey: "userAvatar") as? String else { return }
        if avatarImg != "defaultAvatar" {
            if let imageUrl = URL(string: avatarImg) {
                avatarImgView.kf.setImage(with: imageUrl)
            }
        } else {
            avatarImgView.image = UIImage(named: "\(avatarImg)")
        }
        avatarImgView.contentMode = .scaleAspectFill
        avatarImgView.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressAvatarImgView))
        avatarImgView.addGestureRecognizer(tap)
        avatarImgView.isUserInteractionEnabled = true
        avatarImgView.layer.cornerRadius = 54
        
        avatarImgViewContainer = Blur.shared.setViewShadow(avatarImgViewContainer)
        
        let userName = UserDefaults.standard.object(forKey: "userName")
        userNameLabel.text = "尚未設定名稱"
        userNameLabel.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        userNameLabel.textColor = .white
        
        generalLabel.text = "一般"
        generalLabel.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        generalLabel.textColor = UIColor(hex: CIC.shared.F1)
        
        let symbolSizeForEditBtn: CGFloat = 18
        settingViewEditBtn.setImage(
            UIImage(systemName: "pencil.line")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: symbolSizeForEditBtn)),
            for: .normal
        )
        settingViewEditBtn.tintColor = UIColor(hex: CIC.shared.F1)
        settingViewEditBtn.imageView?.contentMode = .scaleAspectFit
        settingViewEditBtn.addTarget(self, action: #selector(didPressSettingViewEditBtn), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        [avatarImgView, userNameLabel, generalLabel,
         settingViewBackBtn, settingViewEditBtn, avatarImgViewContainer
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            settingViewBackBtn.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            settingViewBackBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            settingViewBackBtn.widthAnchor.constraint(equalToConstant: 36),
            settingViewBackBtn.heightAnchor.constraint(equalToConstant: 36),
            
            avatarImgViewContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImgViewContainer.widthAnchor.constraint(equalToConstant: 108),
            avatarImgViewContainer.heightAnchor.constraint(equalToConstant: 108),
            avatarImgViewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 56),
            
            avatarImgView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImgView.widthAnchor.constraint(equalToConstant: 108),
            avatarImgView.heightAnchor.constraint(equalToConstant: 108),
            avatarImgView.topAnchor.constraint(equalTo: topAnchor, constant: 56),
            
            userNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            userNameLabel.topAnchor.constraint(equalTo: avatarImgView.bottomAnchor, constant: 16),
            
            settingViewEditBtn.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor),
            settingViewEditBtn.leadingAnchor.constraint(equalTo: userNameLabel.trailingAnchor, constant: 4),
            
            generalLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            generalLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 24)
        ])
    }
    
    @objc func didPressSettingViewBackBtn() {
        delegate?.didPressSettingViewBackBtn(self)
    }
    
    @objc func didPressSettingViewEditBtn() {
        delegate?.didPressSettingViewEditBtn(self)
    }
    
    @objc func didPressAvatarImgView() {
        delegate?.presentImagePicker(self)
    }
}
