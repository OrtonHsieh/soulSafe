//
//  PostViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/17.
//

import UIKit

class PostViewController: UIViewController {
    let imageView = UIImageView()
    let textAreaView = TextAreaView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // testing
        setupView()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        textAreaView.inputTextView.layer.cornerRadius = 10
    }
    
    func setupView() {
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        view.addSubview(imageView)
        view.addSubview(textAreaView)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        textAreaView.backgroundColor = UIColor(hex: CIC.shared.M1)
    }
    
    func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 304).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        textAreaView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textAreaView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
