//
//  EditGroupView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/18.
//

import UIKit

protocol EditGroupViewDelegate: AnyObject {
    func didPressQRCodeBtn(_ view: EditGroupView, button: UIButton)
    func didPressGetLinkBtn(_ view: EditGroupView, button: UIButton)
    func didPressLeaveBtn(_ view: EditGroupView, button: UIButton)
    func didPressCopyLinkBtn(_ view: EditGroupView, button: UIButton)
}

class EditGroupView: UIView {
    lazy var createGroupLabel = UILabel()
    lazy var leftHintLabel = UILabel()
    lazy var rightHintLabel = UILabel()
    lazy var leftActionView = UIView()
    lazy var rightActionView = UIView()
    lazy var containerView = UIView()
    lazy var QRCodeBtn = UIButton()
    lazy var leaveBtn = UIButton()
    lazy var shareLinkBtn = UIButton()
    lazy var copyLinkBtn = UIButton()
    
    weak var delegate: EditGroupViewDelegate?

    lazy var titleForLeave = "離開我的群組"
    lazy var titleForCopylink = "複製群組連結"
    lazy var titleForQRCode = "QRCode 掃碼"
    lazy var titleForCreateLink = "建立群組連結"

    lazy var basicView = [createGroupLabel, containerView, leftHintLabel, rightHintLabel]
    lazy var containerViewComponent = [leftActionView, rightActionView]
    lazy var leftActionViewComponent = [QRCodeBtn, leaveBtn]
    lazy var rightActionViewComponent = [copyLinkBtn, shareLinkBtn]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        setupAdditionalConstraints()
    }

    func setupView() {
        basicView.forEach { addSubview($0) }
        containerViewComponent.forEach { containerView.addSubview($0) }
        leftActionViewComponent.forEach { leftActionView.addSubview($0) }
        rightActionViewComponent.forEach { rightActionView.addSubview($0) }

        createGroupLabel.font = .systemFont(ofSize: 20, weight: .medium)
        createGroupLabel.textColor = UIColor(hex: CIC.shared.F1)
        createGroupLabel.text = "建立新的群組"
        createGroupLabel.alpha = 0.8
        createGroupLabel.textAlignment = .center

        containerView.backgroundColor = .clear

        leftActionView = Blur.shared.setViewShadow(leftActionView)
        leftActionView.backgroundColor = UIColor(hex: CIC.shared.M1)

        rightActionView = Blur.shared.setViewShadow(rightActionView)
        rightActionView.backgroundColor = UIColor(hex: CIC.shared.M1)

        leftHintLabel.font = .systemFont(ofSize: 14, weight: .medium)
        leftHintLabel.text = titleForQRCode
        leftHintLabel.textAlignment = .center
        
        rightHintLabel.font = .systemFont(ofSize: 14, weight: .medium)
        rightHintLabel.text = titleForCreateLink
        rightHintLabel.textAlignment = .center

        QRCodeBtn.setImage(UIImage(named: "icon-QRcode"), for: .normal)
        QRCodeBtn.addTarget(self, action: #selector(didPressQRCodeBtn), for: .touchUpInside)
        
        copyLinkBtn.setImage(UIImage(named: "icon-link"), for: .normal)
        copyLinkBtn.addTarget(self, action: #selector(didPressGetLinkBtn), for: .touchUpInside)
        
        leaveBtn.setImage(UIImage(named: "icon-leave"), for: .normal)
        leaveBtn.addTarget(self, action: #selector(didPressLeaveBtn), for: .touchUpInside)
        leaveBtn.isHidden = true
        
        shareLinkBtn.setImage(UIImage(named: "icon-copyLink"), for: .normal)
        shareLinkBtn.addTarget(self, action: #selector(didPressCopyLinkBtn), for: .touchUpInside)
        shareLinkBtn.isHidden = true
    }

    func setupConstraints() {
        basicView.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        containerViewComponent.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        leftActionViewComponent.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        rightActionViewComponent.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        
        NSLayoutConstraint.activate([
            createGroupLabel.topAnchor.constraint(equalTo: topAnchor),
            createGroupLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            createGroupLabel.widthAnchor.constraint(equalToConstant: 150),
            createGroupLabel.heightAnchor.constraint(equalToConstant: 20),

            containerView.topAnchor.constraint(equalTo: createGroupLabel.bottomAnchor, constant: 44),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 58),
            
            leftHintLabel.topAnchor.constraint(equalTo: createGroupLabel.bottomAnchor, constant: 20),
            leftHintLabel.centerXAnchor.constraint(equalTo: leftActionView.centerXAnchor),
            
            rightHintLabel.topAnchor.constraint(equalTo: createGroupLabel.bottomAnchor, constant: 20),
            rightHintLabel.centerXAnchor.constraint(equalTo: rightActionView.centerXAnchor)
        ])
    }
    
    func setupAdditionalConstraints() {
        let constant: CGFloat = 16
        let separatorConstant: CGFloat = 8
        guard let viewWidth = superview?.frame.width else { return }
        
        NSLayoutConstraint.activate([
            leftActionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            leftActionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            leftActionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leftActionView.widthAnchor.constraint(equalToConstant: (viewWidth / 2) - constant - separatorConstant),
            
            rightActionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            rightActionView.widthAnchor.constraint(equalToConstant: (viewWidth / 2) - constant - separatorConstant),
            rightActionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            rightActionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            QRCodeBtn.widthAnchor.constraint(equalToConstant: 40),
            QRCodeBtn.heightAnchor.constraint(equalToConstant: 40),
            QRCodeBtn.centerXAnchor.constraint(equalTo: leftActionView.centerXAnchor),
            QRCodeBtn.centerYAnchor.constraint(equalTo: leftActionView.centerYAnchor),
            
            leaveBtn.widthAnchor.constraint(equalToConstant: 40),
            leaveBtn.heightAnchor.constraint(equalToConstant: 40),
            leaveBtn.centerXAnchor.constraint(equalTo: leftActionView.centerXAnchor),
            leaveBtn.centerYAnchor.constraint(equalTo: leftActionView.centerYAnchor),
            
            copyLinkBtn.widthAnchor.constraint(equalToConstant: 35),
            copyLinkBtn.heightAnchor.constraint(equalToConstant: 35),
            copyLinkBtn.centerXAnchor.constraint(equalTo: rightActionView.centerXAnchor),
            copyLinkBtn.centerYAnchor.constraint(equalTo: rightActionView.centerYAnchor, constant: -1.5),
            
            shareLinkBtn.widthAnchor.constraint(equalToConstant: 35),
            shareLinkBtn.heightAnchor.constraint(equalToConstant: 35),
            shareLinkBtn.centerXAnchor.constraint(equalTo: rightActionView.centerXAnchor),
            shareLinkBtn.centerYAnchor.constraint(equalTo: rightActionView.centerYAnchor, constant: -1.5)
        ])
    }

    @objc func didPressQRCodeBtn() {
        Vibration.shared.lightV()
    }

    @objc func didPressGetLinkBtn() {
        Vibration.shared.lightV()
        delegate?.didPressGetLinkBtn(self, button: copyLinkBtn)
    }

    @objc func didPressLeaveBtn() {
        Vibration.shared.lightV()
    }

    @objc func didPressCopyLinkBtn() {
        Vibration.shared.lightV()
    }
}
