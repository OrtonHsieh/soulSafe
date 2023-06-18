//
//  EditGroupViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/18.
//

import UIKit

class EditGroupViewController: UIViewController {
    lazy var editGroupView = EditGroupView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        editGroupView.getGroupLinkView.layer.cornerRadius = 12
    }
    
    func setupView() {
        view.addSubview(editGroupView)
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
    }
    
    func setupConstraints() {
        editGroupView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            editGroupView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            editGroupView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editGroupView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editGroupView.heightAnchor.constraint(equalToConstant: 198)
        ])
    }
}
