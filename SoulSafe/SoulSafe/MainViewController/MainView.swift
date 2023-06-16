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
    func didPressCloseBtm(_ view: CameraView)
    func didPressSendBtm(_ view: CameraView, image: UIImage)
}

class CameraView: UIView {
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let cameraDisplayView = UIView()
    let picButton = PicButton()
    lazy var buttonCorner = UIView()
    let flashButton = UIButton()
    let reverseButton = UIButton()
    let closeButton = UIButton()
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
        [cameraDisplayView, buttonCorner, flashButton, reverseButton, closeButton, photoImageView, sendButton].forEach {
            addSubview($0)
        }
        buttonCorner.addSubview(picButton)
        buttonCorner.backgroundColor = UIColor(hex: CIC.shared.F2)
        buttonCorner = Blur.shared.setViewShadow(buttonCorner)
        
        picButton.addTarget(self, action: #selector(takePic), for: .touchUpInside)
        
        closeButton.setImage(UIImage(named: "icon-return"), for: .normal)
        closeButton.backgroundColor = UIColor.clear
        closeButton.addTarget(self, action: #selector(closeBtmPressed), for: .touchUpInside)
        closeButton.isHidden = true
        
        photoImageView.contentMode = .scaleAspectFit
        photoImageView = Blur.shared.setImgViewShadow(photoImageView)
        photoImageView.isHidden = true
        
        sendButton = Blur.shared.setButtonShadow(sendButton)
        sendButton.setImage(UIImage(named: "icon-send"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendBtmPressed), for: .touchUpInside)
        sendButton.isHidden = true
    }
    
    func setupConstrants() {
        [cameraDisplayView, buttonCorner, flashButton, reverseButton, picButton, closeButton, photoImageView, sendButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        let cameraWidth: CGFloat = frame.width
        let cameraHeight: CGFloat = (cameraWidth / 325) * 404
        NSLayoutConstraint.activate([
            cameraDisplayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cameraDisplayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cameraDisplayView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cameraDisplayView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -62),
            cameraDisplayView.widthAnchor.constraint(equalToConstant: cameraWidth),
            cameraDisplayView.heightAnchor.constraint(equalToConstant: cameraHeight),
            
            buttonCorner.topAnchor.constraint(equalTo: cameraDisplayView.bottomAnchor, constant: 52),
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
            sendButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupVideoPreviewLayer(session: AVCaptureSession?) {
        guard let session = session else { return }
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = bounds
        
        if let previewLayer = videoPreviewLayer {
            cameraDisplayView.layer.addSublayer(previewLayer)
            
            previewLayer.masksToBounds = false
            previewLayer.shadowColor = UIColor(red: 24 / 255, green: 183 / 255, blue: 231 / 255, alpha: 0.4).cgColor
            previewLayer.shadowOpacity = 1.0
            previewLayer.shadowRadius = 43
            previewLayer.shadowOffset = CGSize(width: 0, height: 0)
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
        delegate?.didPressCloseBtm(self)
    }
    
    @objc func sendBtmPressed() {
        guard let picImage = photoImageView.image else { return }
        delegate?.didPressSendBtm(self, image: picImage)
    }
}
