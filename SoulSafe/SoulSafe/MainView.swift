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
        addSubview(cameraDisplayView)
    }

    func setupConstrants() {
        cameraDisplayView.translatesAutoresizingMaskIntoConstraints = false
        let cameraWidth: CGFloat = frame.width
        let cameraHeight: CGFloat = (cameraWidth / 325) * 404
        NSLayoutConstraint.activate([
            cameraDisplayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cameraDisplayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cameraDisplayView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cameraDisplayView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -62),
            cameraDisplayView.widthAnchor.constraint(equalToConstant: cameraWidth),
            cameraDisplayView.heightAnchor.constraint(equalToConstant: cameraHeight)
        ])
    }
    
    private func setupVideoPreviewLayer(session: AVCaptureSession?) {
        guard let session = session else { return }
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = bounds
        
        if let previewLayer = videoPreviewLayer {
            cameraDisplayView.layer.addSublayer(previewLayer)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: 390, height: 484.79999999999995)
    }
}
