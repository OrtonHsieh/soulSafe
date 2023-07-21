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
    func didPressSettingBtn(_ view: CameraView)
    func didPressMemoriesBtn(_ view: CameraView)
    func didPressReverseBtn(_ view: CameraView)
}

class CameraView: UIView {
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let cameraView = UIView()
    let picButton = PicButton()
    lazy var buttonCorner = UIView()
    let flashButton = UIButton()
    let reverseButton = UIButton()
    let closeButton = UIButton()
    
    let memoriesButton = UIButton()
    
    let settingButton = UIButton()
    
    let mapContainerView = UIView()
    let mapImgView = UIImageView()
    let mapLabel = UILabel()
    
    let groupContainerView = UIView()
    let groupImgView = UIImageView()
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
            mapContainerView, settingButton, memoriesButton
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
        
        let symbolSize: CGFloat = 32
        groupContainerView.backgroundColor = UIColor(hex: CIC.shared.M2)
        let tapGestureForGroup = UITapGestureRecognizer(target: self, action: #selector(groupContainerViewTapped))
        groupContainerView.addGestureRecognizer(tapGestureForGroup)
        groupLabel.text = "群組"
        groupLabel.textColor = UIColor(hex: CIC.shared.F2)
        groupImgView.image = UIImage(systemName: "person.3.fill")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: symbolSize + 2))
        groupImgView.tintColor = UIColor(hex: CIC.shared.F2)
        groupImgView.backgroundColor = .clear
        groupImgView.contentMode = .scaleAspectFit
        
        mapContainerView.backgroundColor = UIColor(hex: CIC.shared.M2)
        let tapGestureForMap = UITapGestureRecognizer(target: self, action: #selector(mapContainerViewTapped))
        mapContainerView.addGestureRecognizer(tapGestureForMap)
        mapLabel.text = "地圖"
        mapLabel.textColor = UIColor(hex: CIC.shared.F2)
        mapImgView.image = UIImage(systemName: "map")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: symbolSize))
        mapImgView.tintColor = UIColor(hex: CIC.shared.F2)
        mapImgView.backgroundColor = .clear
        mapImgView.contentMode = .scaleAspectFit
        
        settingButton.setImage(
            UIImage(systemName: "gearshape")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: symbolSize)),
            for: .normal
        )
        settingButton.tintColor = UIColor(hex: CIC.shared.F2)
        settingButton.backgroundColor = .clear
        settingButton.imageView?.contentMode = .scaleAspectFit
        settingButton.addTarget(self, action: #selector(didPressSettingBtn), for: .touchUpInside)
        
        reverseButton.setImage(
            UIImage(systemName: "arrow.triangle.2.circlepath")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: symbolSize)),
            for: .normal
        )
        reverseButton.tintColor = UIColor(hex: CIC.shared.F2)
        reverseButton.backgroundColor = .clear
        reverseButton.imageView?.contentMode = .scaleAspectFit
        reverseButton.addTarget(self, action: #selector(didPressReverseBtn), for: .touchUpInside)
        
        memoriesButton.setImage(
            UIImage(systemName: "photo.on.rectangle")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: symbolSize)),
            for: .normal
        )
        memoriesButton.tintColor = UIColor(hex: CIC.shared.F2)
        memoriesButton.backgroundColor = .clear
        memoriesButton.imageView?.contentMode = .scaleAspectFit
        memoriesButton.addTarget(self, action: #selector(didPressMemoriesBtn), for: .touchUpInside)
    }
    
    func setupConstrants() {
        let list = [
            cameraView, buttonCorner, flashButton, reverseButton,
            picButton, closeButton, photoImageView, sendButton,
            groupContainerView, groupImgView, groupLabel, mapContainerView,
            mapImgView, mapLabel, settingButton, memoriesButton
        ]
        list.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        let cameraWidth: CGFloat = frame.width
        let cameraHeight: CGFloat = cameraWidth
        NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cameraView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cameraView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -54),
            cameraView.widthAnchor.constraint(equalToConstant: cameraWidth),
            cameraView.heightAnchor.constraint(equalToConstant: cameraHeight),
            
            buttonCorner.topAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: 28),
            buttonCorner.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonCorner.heightAnchor.constraint(equalToConstant: 100),
            buttonCorner.widthAnchor.constraint(equalToConstant: 100),
            
            picButton.centerXAnchor.constraint(equalTo: buttonCorner.centerXAnchor),
            picButton.centerYAnchor.constraint(equalTo: buttonCorner.centerYAnchor),
            
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.leadingAnchor.constraint(equalTo: buttonCorner.trailingAnchor, constant: 50),
            closeButton.topAnchor.constraint(equalTo: buttonCorner.topAnchor, constant: 30),
            
            reverseButton.heightAnchor.constraint(equalToConstant: 40),
            reverseButton.widthAnchor.constraint(equalToConstant: 40),
            reverseButton.leadingAnchor.constraint(equalTo: buttonCorner.trailingAnchor, constant: 50),
            reverseButton.topAnchor.constraint(equalTo: buttonCorner.topAnchor, constant: 30),
            
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            photoImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -54),
            photoImageView.widthAnchor.constraint(equalToConstant: cameraWidth),
            photoImageView.heightAnchor.constraint(equalToConstant: cameraHeight),
            
            sendButton.centerXAnchor.constraint(equalTo: buttonCorner.centerXAnchor),
            sendButton.centerYAnchor.constraint(equalTo: buttonCorner.centerYAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 100),
            sendButton.widthAnchor.constraint(equalToConstant: 100),
            
            groupContainerView.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            ),
            groupContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            groupContainerView.widthAnchor.constraint(equalToConstant: 111),
            groupContainerView.heightAnchor.constraint(equalToConstant: 36),
            
            groupImgView.leadingAnchor.constraint(equalTo: groupContainerView.leadingAnchor, constant: 15),
            groupImgView.centerYAnchor.constraint(equalTo: groupContainerView.centerYAnchor),
            groupImgView.widthAnchor.constraint(equalToConstant: 34),
            groupImgView.heightAnchor.constraint(equalToConstant: 34),
            
            groupLabel.trailingAnchor.constraint(equalTo: groupContainerView.trailingAnchor, constant: -15),
            groupLabel.centerYAnchor.constraint(equalTo: groupContainerView.centerYAnchor),
            
            mapContainerView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            mapContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mapContainerView.widthAnchor.constraint(equalToConstant: 111),
            mapContainerView.heightAnchor.constraint(equalToConstant: 36),
            
            mapImgView.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor, constant: 15),
            mapImgView.centerYAnchor.constraint(equalTo: mapContainerView.centerYAnchor),
            mapImgView.widthAnchor.constraint(equalToConstant: 30),
            mapImgView.heightAnchor.constraint(equalToConstant: 30),
            
            mapLabel.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor, constant: -15),
            mapLabel.centerYAnchor.constraint(equalTo: mapContainerView.centerYAnchor),
            
            memoriesButton.centerYAnchor.constraint(equalTo: mapContainerView.centerYAnchor),
            memoriesButton.widthAnchor.constraint(equalToConstant: 36),
            memoriesButton.heightAnchor.constraint(equalToConstant: 36),
            memoriesButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            settingButton.centerYAnchor.constraint(equalTo: mapContainerView.centerYAnchor),
            settingButton.widthAnchor.constraint(equalToConstant: 32),
            settingButton.heightAnchor.constraint(equalToConstant: 32),
            settingButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
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
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = frame.width
        let height = width
        videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: width, height: height)
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
    
    @objc func didPressMemoriesBtn() {
        delegate?.didPressMemoriesBtn(self)
    }
    
    @objc func didPressSettingBtn() {
        delegate?.didPressSettingBtn(self)
    }
    
    @objc func didPressReverseBtn() {
        delegate?.didPressReverseBtn(self)
    }
}
