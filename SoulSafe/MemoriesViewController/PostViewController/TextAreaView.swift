//
//  TextAreaView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/17.
//

import UIKit
import GrowingTextView

protocol TextAreaViewDelegate: AnyObject {
    func didSendCmt(_ view: TextAreaView, comment: String)
}

class TextAreaView: UIView {
    weak var delegate: TextAreaViewDelegate?
    
    lazy var inputTextView: UITextView = {
        let textView = GrowingTextView()
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 36)
        textView.backgroundColor = UIColor(hex: CIC.shared.M1)
        textView.layer.borderColor = UIColor(hex: CIC.shared.F2).cgColor
        textView.layer.borderWidth = 1
        textView.textColor = .white
        textView.minHeight = 52
        textView.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        textView.delegate = self
        return textView
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon-bigBack"), for: .normal)
        button.addTarget(self, action: #selector(buttonDidPress), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.backgroundColor = UIColor(hex: CIC.shared.M1)
        addSubview(inputTextView)
        inputTextView.addSubview(sendButton)
    }
    
    func setupConstraints() {
        [inputTextView, sendButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        let constant: CGFloat = 8
        
        NSLayoutConstraint.activate([
            inputTextView.topAnchor.constraint(equalTo: topAnchor),
            inputTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constant),
            inputTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constant),
            inputTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -constant),
            
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constant * 1.5),
            sendButton.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc private func buttonDidPress() {
        print("send message")
        delegate?.didSendCmt(self, comment: inputTextView.text)
    }
}

extension TextAreaView: UITextViewDelegate {}
