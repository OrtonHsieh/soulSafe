//
//  MainView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/15.
//

import UIKit
import AVFoundation

class CameraView: UIView {
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let cameraDisplayView = UIView()
    let picButton = PicButton()
    let buttonCorner = UIView()
    let flashButton = UIButton()
    let reverseButton = UIButton()
    
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
        [cameraDisplayView, buttonCorner, flashButton, reverseButton].forEach { addSubview($0) }
        buttonCorner.addSubview(picButton)
        buttonCorner.backgroundColor = UIColor(hex: CIC.shared.F2)
        
        picButton.addTarget(self, action: #selector(takePic), for: .touchUpInside)
    }

    func setupConstrants() {
        [cameraDisplayView, buttonCorner, flashButton, reverseButton, buttonCorner, picButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
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
//            previewLayer.cornerRadius = 30
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: 390, height: 484.79999999999995)
//        videoPreviewLayer?.cornerRadius = 30
    }
    
    @objc func takePic() {
        print("拍照")
        
    }
}
