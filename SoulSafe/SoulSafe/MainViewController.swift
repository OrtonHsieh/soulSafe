//
//  ViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/14.
//
    
import AVFoundation
import UIKit

class MainViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var cameraView: CameraView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
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
            view.addSubview(cameraView)
            
            DispatchQueue.global(qos: .background).async {
                // Start running the capture session
                captureSession.startRunning()
            }
        } catch {
            print("Error setting up capture device: \(error.localizedDescription)")
        }
        
        view.layoutIfNeeded() // ??? 檢查是否需要以及其機制
    }
    
    override func viewDidLayoutSubviews() {
//        cameraView?.cameraDisplayView.layer.masksToBounds = false
//        cameraView?.cameraDisplayView.clipsToBounds = true
//        cameraView?.cameraDisplayView.layer.cornerRadius = 43
//        cameraView?.cameraDisplayView.layer.shadowOffset = CGSize(width: 0, height: 0)
//        cameraView?.cameraDisplayView.layer.shadowColor = UIColor(red: 24/255, green: 183/255, blue: 231/255, alpha: 0.4).cgColor
//        cameraView?.cameraDisplayView.layer.shadowOpacity = 1.0
        
//        cameraView?.videoPreviewLayer?.cornerRadius = 30
        
        // 紀錄：這邊如果是設定在 view 上面的效果較不明顯，但相同設定，設定在 AVLayer 上就會有預期的效果但會讓 raidus 消失
        //            previewLayer.masksToBounds = false
        //            previewLayer.shadowColor = UIColor(red: 24/255, green: 183/255, blue: 231/255, alpha: 0.4).cgColor
        //            previewLayer.shadowOpacity = 1.0
        //            previewLayer.shadowRadius = 43
        //            previewLayer.shadowOffset = CGSize(width: 0, height: 0)
        cameraView?.buttonCorner.layer.cornerRadius = 50
    }
    
    // Capture photo button action
    @objc func capturePhotoButtonTapped() {
        guard let photoOutput = self.photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
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
        
        // Process and save the captured photo as needed
        // ...
    }
}
