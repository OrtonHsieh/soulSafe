//
//  EditNameViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/18.
//

import UIKit

protocol EditNameViewControllerDelegate: AnyObject {
    func didPressSaveBtn(_ view: EditNameViewController, name: String)
}

class EditNameViewController: UIViewController {
    lazy var editNameView = EditNameView()
    weak var delegate: EditNameViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    func setupView() {
        view.addSubview(editNameView)
        editNameView.backgroundColor = UIColor(hex: CIC.shared.M1)
        editNameView.delegate = self
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
    }
    
    func setupConstraints() {
        editNameView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editNameView.topAnchor.constraint(equalTo: view.topAnchor),
            editNameView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editNameView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editNameView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension EditNameViewController: EditNameViewDelegate {
    func didPressSaveBtn(_ view: EditNameView, name: String) {
        Vibration.shared.lightV()
        delegate?.didPressSaveBtn(self, name: name)
        dismiss(animated: true)
    }
}
