//
//  MainView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/15.
//

import UIKit
import AVFoundation

protocol CameraViewDelegate: AnyObject {
    func didTakePic(_ view: CameraView)
    func didPressCloseBtn(_ view: CameraView)
    func didPressSendBtn(_ view: CameraView, image: UIImage)
    func didPressGroupBtn(_ view: CameraView)
    func didPressMapBtn(_ view: CameraView)
}

class CameraView: UIView {
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let cameraView = UIView()
    let picButton = PicButton()
    lazy var buttonCorner = UIView()
    let flashButton = UIButton()
    let reverseButton = UIButton()
    let closeButton = UIButton()
    
    let mapContainerView = UIView()
    let mapImgView = UIImageView(image: UIImage(named: "icon-map"))
    let mapLabel = UILabel()
    
    let groupContainerView = UIView()
    let groupImgView = UIImageView(image: UIImage(named: "icon-community"))
    let groupLabel = UILabel()
    lazy var sendButton = UIButton()
    lazy var photoImageView = UIImageView()
    weak var delegate: CameraViewDelegate?
    
    init(frame: CGRect, session: AVCaptureSession) {
        super.init(frame: frame)
        setupView()
        setupConstrants()
        setupVideoPreviewLayer(session: session)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupVideoPreviewLayer(session: nil)
    }
    
    func setupView() {
        [
            cameraView, buttonCorner, flashButton, reverseButton,
            closeButton, photoImageView, sendButton, groupContainerView,
            mapContainerView
        ].forEach {
            addSubview($0)
        }
        [groupImgView, groupLabel].forEach {
            groupContainerView.addSubview($0)
        }
        [mapImgView, mapLabel].forEach {
            mapContainerView.addSubview($0)
        }
        buttonCorner.addSubview(picButton)
        buttonCorner.backgroundColor = UIColor(hex: CIC.shared.F2)
        buttonCorner = Blur.shared.setViewShadow(buttonCorner)
        
        picButton.addTarget(self, action: #selector(takePic), for: .touchUpInside)
        
        closeButton.setImage(UIImage(named: "icon-return"), for: .normal)
        closeButton.backgroundColor = UIColor.clear
        closeButton.addTarget(self, action: #selector(closeBtmPressed), for: .touchUpInside)
        closeButton.isHidden = true
        // 光暈沒有真正吃到參數
        photoImageView.contentMode = .scaleAspectFit
        photoImageView = Blur.shared.setImgViewShadow(photoImageView)
        photoImageView.isHidden = true
        
        sendButton = Blur.shared.setButtonShadow(sendButton)
        sendButton.setImage(UIImage(named: "icon-send-disabled"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendBtmPressed), for: .touchUpInside)
        sendButton.isEnabled = false
        sendButton.isHidden = true
        
        groupContainerView.backgroundColor = UIColor(hex: CIC.shared.M2)
        let tapGestureForGroup = UITapGestureRecognizer(target: self, action: #selector(groupContainerViewTapped))
        groupContainerView.addGestureRecognizer(tapGestureForGroup)
        groupLabel.text = "群組"
        groupLabel.textColor = UIColor(hex: CIC.shared.F2)
        
        mapContainerView.backgroundColor = UIColor(hex: CIC.shared.M2)
        let tapGestureForMap = UITapGestureRecognizer(target: self, action: #selector(mapContainerViewTapped))
        mapContainerView.addGestureRecognizer(tapGestureForMap)
        mapLabel.text = "地圖"
        mapLabel.textColor = UIColor(hex: CIC.shared.F2)
    }
    
    func setupConstrants() {
        let list = [
            cameraView, buttonCorner, flashButton, reverseButton, picButton, closeButton, photoImageView, sendButton,
            groupContainerView, groupImgView, groupLabel, mapContainerView, mapImgView, mapLabel
        ]
        list.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        let cameraWidth: CGFloat = frame.width
        let cameraHeight: CGFloat = (cameraWidth / 325) * 404
        NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cameraView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cameraView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -62),
            cameraView.widthAnchor.constraint(equalToConstant: cameraWidth),
            cameraView.heightAnchor.constraint(equalToConstant: cameraHeight),
            
            buttonCorner.topAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: 32),
            buttonCorner.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonCorner.heightAnchor.constraint(equalToConstant: 100),
            buttonCorner.widthAnchor.constraint(equalToConstant: 100),
            
            picButton.centerXAnchor.constraint(equalTo: buttonCorner.centerXAnchor),
            picButton.centerYAnchor.constraint(equalTo: buttonCorner.centerYAnchor),
            
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.leadingAnchor.constraint(equalTo: buttonCorner.trailingAnchor, constant: 50),
            closeButton.topAnchor.constraint(equalTo: buttonCorner.topAnchor, constant: 30),
            
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            photoImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -62),
            photoImageView.widthAnchor.constraint(equalToConstant: cameraWidth),
            photoImageView.heightAnchor.constraint(equalToConstant: cameraHeight),
            
            sendButton.centerXAnchor.constraint(equalTo: buttonCorner.centerXAnchor),
            sendButton.centerYAnchor.constraint(equalTo: buttonCorner.centerYAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 100),
            sendButton.widthAnchor.constraint(equalToConstant: 100),
            
            groupContainerView.topAnchor.constraint(equalTo: buttonCorner.bottomAnchor, constant: 25),
            groupContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            groupContainerView.widthAnchor.constraint(equalToConstant: 111),
            groupContainerView.heightAnchor.constraint(equalToConstant: 36),
            
            groupImgView.leadingAnchor.constraint(equalTo: groupContainerView.leadingAnchor, constant: 15),
            groupImgView.centerYAnchor.constraint(equalTo: groupContainerView.centerYAnchor),
            groupImgView.widthAnchor.constraint(equalToConstant: 30),
            groupImgView.heightAnchor.constraint(equalToConstant: 30),
            
            groupLabel.trailingAnchor.constraint(equalTo: groupContainerView.trailingAnchor, constant: -15),
            groupLabel.centerYAnchor.constraint(equalTo: groupContainerView.centerYAnchor),
            
            mapContainerView.bottomAnchor.constraint(equalTo: cameraView.topAnchor, constant: -25),
            mapContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mapContainerView.widthAnchor.constraint(equalToConstant: 111),
            mapContainerView.heightAnchor.constraint(equalToConstant: 36),
            
            mapImgView.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor, constant: 15),
            mapImgView.centerYAnchor.constraint(equalTo: mapContainerView.centerYAnchor),
            mapImgView.widthAnchor.constraint(equalToConstant: 30),
            mapImgView.heightAnchor.constraint(equalToConstant: 30),
            
            mapLabel.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor, constant: -15),
            mapLabel.centerYAnchor.constraint(equalTo: mapContainerView.centerYAnchor),
        ])
    }
    
    private func setupVideoPreviewLayer(session: AVCaptureSession?) {
        guard let session = session else { return }
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = bounds
        
        if let previewLayer = videoPreviewLayer {
            cameraView.layer.addSublayer(previewLayer)
            
            cameraView.layer.masksToBounds = true
            cameraView.layer.cornerRadius = 30
            cameraView.layer.shouldRasterize = true
            cameraView.layer.rasterizationScale = UIScreen.main.scale
            
            // 這邊光暈現在吃不到參數
//            previewLayer.masksToBounds = false
//            previewLayer.shadowColor = UIColor(red: 24 / 255, green: 183 / 255, blue: 231 / 255, alpha: 0.4).cgColor
//            previewLayer.shadowOpacity = 1.0
//            previewLayer.shadowRadius = 43
//            previewLayer.shadowOffset = CGSize(width: 0, height: 0)
//
//            previewLayer.cornerRadius = 30
//            previewLayer.shouldRasterize = true
//            previewLayer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: 390, height: 484.79999999999995)
        //        videoPreviewLayer?.cornerRadius = 30
    }
    
    @objc func takePic() {
        delegate?.didTakePic(self)
    }
    
    @objc func closeBtmPressed() {
        delegate?.didPressCloseBtn(self)
    }
    
    @objc func sendBtmPressed() {
        guard let picImage = photoImageView.image else { return }
        delegate?.didPressSendBtn(self, image: picImage)
    }
    
    @objc func groupContainerViewTapped() {
        delegate?.didPressGroupBtn(self)
    }
    
    @objc func mapContainerViewTapped() {
        delegate?.didPressMapBtn(self)
    }
}
