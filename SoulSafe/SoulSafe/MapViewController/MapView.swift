//
//  MapView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/3.
//

import UIKit
import MapKit

protocol MapViewDelegate: AnyObject {
    func didPressCloseBtnOfMapView(_ view: MapView)
}

class MapView: UIView {
    lazy var map = MKMapView()
    lazy private var closeBtn = UIButton()
    weak var delegate: MapViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        [map, closeBtn].forEach { addSubview($0) }
        closeBtn.setImage(UIImage(named: "icon-close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(didPressCloseBtnOfMapView), for: .touchUpInside)
    }
    
    func setupConstraints() {
        [map, closeBtn].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            closeBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeBtn.heightAnchor.constraint(equalToConstant: 40),
            closeBtn.widthAnchor.constraint(equalToConstant: 40),
            
            map.topAnchor.constraint(equalTo: topAnchor),
            map.leadingAnchor.constraint(equalTo: leadingAnchor),
            map.trailingAnchor.constraint(equalTo: trailingAnchor),
            map.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc func didPressCloseBtnOfMapView() {
        delegate?.didPressCloseBtnOfMapView(self)
    }
}
