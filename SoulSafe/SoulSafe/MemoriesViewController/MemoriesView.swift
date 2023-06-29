//
//  MemoriesView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/16.
//

import UIKit

protocol MemoriesViewDelegate: AnyObject {
    func didPressGroupSelector(_ view: MemoriesView)
}

class MemoriesView: UIView {
    lazy var groupSelectorLabel = UILabel()
    private let backButton = UIButton()
    weak var delegate: MemoriesViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        groupSelectorLabel.layer.cornerRadius = 10
    }
    
    func setupView() {
        [groupSelectorLabel, backButton].forEach { addSubview($0) }
        backButton.setImage(UIImage(named: "icon-bigBack"), for: .normal)
        backButton.addTarget(self, action: #selector(buttonDidPress), for: .touchUpInside)
        
        groupSelectorLabel.layer.borderWidth = 1
        groupSelectorLabel.layer.borderColor = UIColor(hex: CIC.shared.F2).cgColor
        groupSelectorLabel.clipsToBounds = true
        groupSelectorLabel.backgroundColor = UIColor(hex: CIC.shared.M2)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didClickGroupSelector))
        groupSelectorLabel.addGestureRecognizer(tap)
        groupSelectorLabel.isUserInteractionEnabled = true

        groupSelectorLabel.textColor = UIColor(hex: CIC.shared.F1)
        groupSelectorLabel.text = "我的貼文"
        groupSelectorLabel.textAlignment = .center
    }
    
    func setupConstraints() {
        [groupSelectorLabel, backButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        let spec: CGFloat = 36
        NSLayoutConstraint.activate([
            groupSelectorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            groupSelectorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            groupSelectorLabel.widthAnchor.constraint(equalToConstant: 148),
            groupSelectorLabel.heightAnchor.constraint(equalToConstant: 40),
            
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            backButton.widthAnchor.constraint(equalToConstant: spec),
            backButton.heightAnchor.constraint(equalToConstant: spec)
        ])
    }
    
    @objc func buttonDidPress() {
        print("滑動回去 mainVC")
    }
    
    @objc func didClickGroupSelector() {
        print("選項片集")
        Vibration.shared.lightV()
        delegate?.didPressGroupSelector(self)
    }
}
