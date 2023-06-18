//
//  ViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/14.
//

import AVFoundation
import UIKit

protocol MainViewControllerDelegate: AnyObject {
    func didSentImg(_ mainVC: MainViewController, image: UIImage)
}

class MainViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var cameraView: CameraView?
    weak var deletage: MainViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        createCamera()
    }
    
    override func viewDidLayoutSubviews() {
        cameraView?.buttonCorner.layer.cornerRadius = 50
        cameraView?.groupContainerView.layer.cornerRadius = 18
    }
    
    func createCamera() {
        // Set up capture session
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        // Set session preset
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }
        
        // Set up capture device
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Add input to session
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            // Set up photo output
            photoOutput = AVCapturePhotoOutput()
            guard let photoOutput = photoOutput else { return }
            
            // Add output to session
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            // Create and add camera view
            cameraView = CameraView(frame: view.bounds, session: captureSession)
            guard let cameraView = cameraView else { return }
            cameraView.delegate = self
            view.addSubview(cameraView)
            
            DispatchQueue.global(qos: .background).async {
                // Start running the capture session
                captureSession.startRunning()
            }
        } catch {
            print("Error setting up capture device: \(error.localizedDescription)")
        }
    }
}

extension MainViewController: AVCapturePhotoCaptureDelegate {
    // AVCapturePhotoCaptureDelegate methods
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        if let image = UIImage(data: imageData) {
            cameraView?.photoImageView.image = image
            cameraView?.photoImageView.contentMode = .scaleAspectFill
            // 設置圓角目前會導致光暈吃不到參數
            cameraView?.photoImageView.layer.cornerRadius = 30
            cameraView?.photoImageView.layer.masksToBounds = true
            cameraView?.photoImageView.layer.shouldRasterize = true
            cameraView?.photoImageView.layer.rasterizationScale = UIScreen.main.scale

            cameraView?.photoImageView.isHidden = false
            cameraView?.cameraView.isHidden = true
            cameraView?.closeButton.isHidden = false
            cameraView?.picButton.isHidden = true
            cameraView?.buttonCorner.isHidden = true
            cameraView?.sendButton.isHidden = false
        }
    }
}

extension MainViewController: CameraViewDelegate {
    func didTakePic(_ view: CameraView) {
        guard let photoOutput = self.photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func didPressCloseBtn(_ view: CameraView) {
        Vibration.shared.mediumV()
        cameraView?.photoImageView.isHidden = true
        cameraView?.cameraView.isHidden = false
        cameraView?.closeButton.isHidden = true
        cameraView?.buttonCorner.isHidden = false
        cameraView?.picButton.isHidden = false
        cameraView?.sendButton.isHidden = true
    }
    
    func didPressSendBtn(_ view: CameraView, image: UIImage) {
        Vibration.shared.lightV()
        cameraView?.photoImageView.isHidden = true
        cameraView?.cameraView.isHidden = false
        cameraView?.closeButton.isHidden = true
        cameraView?.buttonCorner.isHidden = false
        cameraView?.picButton.isHidden = false
        cameraView?.sendButton.isHidden = true
        deletage?.didSentImg(self, image: image)
    }
    
    func didPressGroupBtn(_ view: CameraView) {
        let groupVC = GroupViewController()
        groupVC.modalPresentationStyle = .formSheet
        Vibration.shared.lightV()
        
        present(groupVC, animated: true)
        
        if let sheetPC = groupVC.sheetPresentationController {
            sheetPC.detents = [.medium()]
            sheetPC.prefersGrabberVisible = true
            sheetPC.delegate = self
            sheetPC.preferredCornerRadius = 20
        }
    }
}

extension MainViewController: UISheetPresentationControllerDelegate {
}
