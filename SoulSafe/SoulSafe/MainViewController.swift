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
    }
    
    override func viewDidLayoutSubviews() {
        cameraView?.cameraDisplayView.layer.cornerRadius = 30
        cameraView?.cameraDisplayView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cameraView?.cameraDisplayView.layer.shadowColor = UIColor(hex: "18B7E7").cgColor
        cameraView?.cameraDisplayView.layer.shadowOpacity = 4
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
