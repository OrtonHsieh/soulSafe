//
//  TextAreaView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/17.
//

import UIKit

class TextAreaView: UIView {
    lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 36)
        textView.backgroundColor = UIColor(hex: CIC.shared.M1)
        textView.isScrollEnabled = false
        textView.layer.borderColor = UIColor(hex: CIC.shared.F2).cgColor
        textView.layer.borderWidth = 1
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        textView.delegate = self
        return textView
    }()
    
    private var textViewHeightConstraint: NSLayoutConstraint!
    private var defaultHeight: CGFloat = 52
    
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
        
        textViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: defaultHeight)
        textViewHeightConstraint.isActive = true
        
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
    
    private func updateTextViewHeight() {
        let numberOfLines = inputTextView.numberOfLines()
        if inputTextView.contentSize.height > defaultHeight {
            textViewHeightConstraint.constant = defaultHeight + defaultHeight
            defaultHeight += defaultHeight
        } else {
            textViewHeightConstraint.constant = inputTextView.contentSize.height
        }
    }
    
    @objc private func buttonDidPress() {
        print("send message")
    }
}

extension TextAreaView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
           updateTextViewHeight()
    }
}

extension UITextView {
    func numberOfLines() -> Int {
        guard let text = self.text else {
            return 0
        }
        
        let textHeight = self.contentSize.height
        let lineHeight = self.font?.lineHeight ?? 0
        let numberOfLines = Int(round(textHeight / lineHeight))
        
        return numberOfLines
    }
}

//extension UITextView {
//    func numberOfLines() -> Int {
//        guard let text = self.text else {
//            return 0
//        }
//
//        let layoutManager = self.layoutManager
//        let textContainer = self.textContainer
//
//        layoutManager.ensureLayout(for: textContainer)
//
//        let numberOfGlyphs = layoutManager.numberOfGlyphs
//        var numberOfLines = 0
//        var lineRange: NSRange = NSRange(location: NSNotFound, length: 0)
//
//        for index in 0..<numberOfGlyphs {
//            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
//            if lineRange.location == NSNotFound {
//                break
//            }
//            numberOfLines += 1
//        }
//
//        return numberOfLines
//    }
//}
