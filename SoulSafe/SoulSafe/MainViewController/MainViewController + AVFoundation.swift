//
//  MainViewController + AVFoundation.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/8.
//

import UIKit
import AVFoundation

extension MainViewController: AVCapturePhotoCaptureDelegate {
    // AVCapturePhotoCaptureDelegate methods
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        if let image = UIImage(data: imageData) {
            // Check if the current camera is the front camera
            let isFrontCamera = currentCamera == .front
            guard let cgImg = image.cgImage else { return }
            let flippedImage = isFrontCamera ? UIImage(
                cgImage: cgImg,
                scale: image.scale,
                orientation: .leftMirrored) : image
            cameraView?.photoImageView.image = flippedImage
            cameraView?.photoImageView.contentMode = .scaleAspectFill
            // 設置圓角目前會導致光暈吃不到參數
            cameraView?.photoImageView.layer.cornerRadius = 30
            cameraView?.photoImageView.layer.masksToBounds = true
            cameraView?.photoImageView.layer.shouldRasterize = true
            cameraView?.photoImageView.layer.rasterizationScale = UIScreen.main.scale
            conponentsArrangementWhenCameraOff()
        }
    }
}
