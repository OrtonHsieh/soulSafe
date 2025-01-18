//
//  EditNameView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/18.
//

import UIKit

protocol EditNameViewDelegate: AnyObject {
    func didPressSaveBtn(_ view: EditNameView, name: String)
}

class EditNameView: UIView {
    private lazy var myNameTitleLabel = UILabel()
    private lazy var myNameTextField = UITextField()
    private lazy var saveBtn = UIButton()
    private lazy var placeholderLabel = UILabel()
    weak var delegate: EditNameViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addPadding()
        setupConstraints()
        showPlaceholder(in: self, withText: "輸入名稱")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [myNameTextField, myNameTitleLabel, saveBtn].forEach { addSubview($0) }
        
        myNameTitleLabel.text = "設定名稱"
        myNameTitleLabel.font = UIFont.systemFont(ofSize: 24)
        myNameTitleLabel.textColor = .white
        
        myNameTextField.textColor = .white
        myNameTextField.font = UIFont.systemFont(ofSize: 18)
        myNameTextField.backgroundColor = UIColor(hex: CIC.shared.M2)
        myNameTextField.layer.cornerRadius = 12
        myNameTextField.delegate = self
        
        saveBtn.setTitle("儲存", for: .normal)
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.imageView?.contentMode = .scaleAspectFit
        saveBtn.addTarget(self, action: #selector(didPressSaveBtn), for: .touchUpInside)
        saveBtn.backgroundColor = UIColor(hex: CIC.shared.F1)
        saveBtn.layer.cornerRadius = 12
        saveBtn.isUserInteractionEnabled = false
    }
    
    private func addPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        myNameTextField.leftView = paddingView
        myNameTextField.leftViewMode = .always
    }
    
    private func setupConstraints() {
        [myNameTextField, myNameTitleLabel, saveBtn].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            myNameTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 36),
            myNameTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            myNameTextField.topAnchor.constraint(equalTo: myNameTitleLabel.bottomAnchor, constant: 28),
            myNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            myNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            myNameTextField.heightAnchor.constraint(equalToConstant: 52),
            
            saveBtn.topAnchor.constraint(equalTo: myNameTextField.bottomAnchor, constant: 32),
            saveBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            saveBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            saveBtn.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    private func showPlaceholder(in view: UIView, withText text: String) {
        placeholderLabel.text = text
        placeholderLabel.textColor = .gray
        placeholderLabel.textAlignment = .center
        
        view.addSubview(placeholderLabel)
        
        // 設置 label 的約束
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.centerYAnchor.constraint(equalTo: myNameTextField.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: myNameTextField.leadingAnchor, constant: 8)
        ])
    }
    
    @objc func didPressSaveBtn() {
        if myNameTextField.text?.isEmpty == false {
            guard let myName = myNameTextField.text else { return }
            saveBtn.isUserInteractionEnabled = true
            delegate?.didPressSaveBtn(self, name: myName)
        } else {
            isUserInteractionEnabled = false
        }
    }
}

extension EditNameView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == myNameTextField {
            placeholderLabel.isHidden = true
            saveBtn.isUserInteractionEnabled = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == myNameTextField {
            if myNameTextField.text?.isEmpty == true {
                placeholderLabel.isHidden = false
            } else {
                saveBtn.isUserInteractionEnabled = true
            }
        }
    }
}
