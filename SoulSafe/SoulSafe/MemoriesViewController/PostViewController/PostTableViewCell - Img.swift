//
//  PostTableViewCell - Img.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/17.
//

import UIKit

class PostTBCellImg: UITableViewCell {
    lazy var postImgView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(postImgView)
        
        postImgView.contentMode = .scaleAspectFill
        postImgView.clipsToBounds = true
    }
    
    func setupConstraints() {
        postImgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            postImgView.topAnchor.constraint(equalTo: topAnchor),
            postImgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            postImgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            postImgView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

