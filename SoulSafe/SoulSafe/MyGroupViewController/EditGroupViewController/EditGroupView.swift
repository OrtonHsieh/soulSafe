//
//  EditGroupView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/18.
//

import UIKit

class EditGroupView: UIView {
    lazy var createGroupLabel = UILabel()
    lazy var editGroupLabel = UILabel()
    lazy var hintLabel = UILabel()
    lazy var getGroupLinkView = UIView()
    lazy var separatorView = UIView()
    lazy var QRCodeBtn = UIButton()
    lazy var copyLinkBtn = UIButton()
    lazy var BSlist = [createGroupLabel, editGroupLabel, hintLabel, getGroupLinkView]
    lazy var groupLinkViewList = [separatorView, QRCodeBtn, copyLinkBtn]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        BSlist.forEach { addSubview($0) }
        groupLinkViewList.forEach { addSubview($0) }
        
        createGroupLabel.font = .systemFont(ofSize: 20, weight: .medium)
        createGroupLabel.textColor = UIColor(hex: CIC.shared.F1)
        createGroupLabel.text = "建立新的群組"
        createGroupLabel.alpha = 0.8
        
        editGroupLabel.font = .systemFont(ofSize: 20, weight: .medium)
        editGroupLabel.textColor = UIColor(hex: CIC.shared.F1)
        editGroupLabel.text = "管理我的群組"
        editGroupLabel.alpha = 0.8
        
        hintLabel.font = .systemFont(ofSize: 14, weight: .medium)
        hintLabel.text = "複製底下連結邀請朋友加入群組"
        
        getGroupLinkView = Blur.shared.setViewShadow(getGroupLinkView)
        getGroupLinkView.backgroundColor = UIColor(hex: CIC.shared.M1)
        
        QRCodeBtn.setImage(UIImage(named: "icon-QRcode"), for: .normal)
        QRCodeBtn.addTarget(self, action: #selector(didPressQRCodeBtn), for: .touchUpInside)
        
        copyLinkBtn.setImage(UIImage(named: "icon-link"), for: .normal)
        copyLinkBtn.addTarget(self, action: #selector(didPressCopyLinkBtn), for: .touchUpInside)
        
        separatorView.backgroundColor = UIColor(hex: CIC.shared.M2)
    }
    
    func setupConstraints() {
        BSlist.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        groupLinkViewList.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        let vieWidth: CGFloat = 300
        let QRCodeConstant: CGFloat = (vieWidth / 4) - 20
        let copyLinkConstant: CGFloat = (vieWidth / 4) - 17
        
        NSLayoutConstraint.activate([
            createGroupLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            createGroupLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            hintLabel.topAnchor.constraint(equalTo: createGroupLabel.bottomAnchor, constant: 12),
            hintLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            getGroupLinkView.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 28),
            getGroupLinkView.widthAnchor.constraint(equalToConstant: vieWidth),
            getGroupLinkView.heightAnchor.constraint(equalToConstant: 54),
            getGroupLinkView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            QRCodeBtn.centerYAnchor.constraint(equalTo: getGroupLinkView.centerYAnchor),
            QRCodeBtn.widthAnchor.constraint(equalToConstant: 40),
            QRCodeBtn.heightAnchor.constraint(equalToConstant: 40),
            QRCodeBtn.leadingAnchor.constraint(equalTo: getGroupLinkView.leadingAnchor, constant: QRCodeConstant),
            
            separatorView.centerYAnchor.constraint(equalTo: getGroupLinkView.centerYAnchor),
            separatorView.centerXAnchor.constraint(equalTo: getGroupLinkView.centerXAnchor),
            separatorView.topAnchor.constraint(equalTo: getGroupLinkView.topAnchor),
            separatorView.bottomAnchor.constraint(equalTo: getGroupLinkView.bottomAnchor),
            separatorView.widthAnchor.constraint(equalToConstant: 3),
            
            copyLinkBtn.centerYAnchor.constraint(equalTo: getGroupLinkView.centerYAnchor, constant: -1),
            copyLinkBtn.widthAnchor.constraint(equalToConstant: 35),
            copyLinkBtn.heightAnchor.constraint(equalToConstant: 35),
            copyLinkBtn.trailingAnchor.constraint(equalTo: getGroupLinkView.trailingAnchor, constant: -copyLinkConstant),
            
            editGroupLabel.topAnchor.constraint(equalTo: getGroupLinkView.bottomAnchor, constant: 28),
            editGroupLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    @objc func didPressQRCodeBtn() {
        Vibration.shared.lightV()
    }
    
    @objc func didPressCopyLinkBtn() {
        Vibration.shared.lightV()
    }
}
