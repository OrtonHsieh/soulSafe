//
//  ViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/14.
//

import AVFoundation
import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

protocol MainViewControllerDelegate: AnyObject {
    func didUpdateGroupID(_ viewController: MainViewController, updatedGroupIDs: [String])
    func didUpdateGroupTitle(_ viewController: MainViewController, updatedGroupTitles: [String])
    func didPressSendBtn(_ viewController: MainViewController)
    func didPressSettingBtn(_ viewController: MainViewController)
    func didPressMemoriesBtn(_ viewController: MainViewController)
}

class MainViewController: UIViewController {
    let viewModel = MainViewModel()
    var captureSession: AVCaptureSession?
    var currentCamera: AVCaptureDevice.Position = .back
    var photoOutput: AVCapturePhotoOutput?
    var cameraView: CameraView?
    weak var delegate: MainViewControllerDelegate?
    // swiftlint:disable all
    let db = Firestore.firestore()
    // swiftlint:enable all
    let mapViewController = MapViewController()
    var groupTitles: [String] = [] {
        didSet {
            delegate?.didUpdateGroupTitle(self, updatedGroupTitles: groupTitles)
            mapViewController.groupTitles = groupTitles
        }
    }
    var groupIDs: [String] = [] {
        didSet {
            delegate?.didUpdateGroupID(self, updatedGroupIDs: groupIDs)
            mapViewController.groupIDs = groupIDs
        }
    }
    let groupVC = GroupViewController()
    let groupStackView = GroupSelectionStackView()
    var selectedGroupDict: [String: [Any]] = [:] {
        didSet {
            if !selectedGroupDict.isEmpty {
                cameraView?.sendButton.setImage(UIImage(named: "icon-send"), for: .normal)
                cameraView?.sendButton.isEnabled = true
            } else {
                cameraView?.sendButton.setImage(UIImage(named: "icon-send-disabled"), for: .normal)
                cameraView?.sendButton.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
        createCamera()
        getGroupData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.stopRunning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        cameraView?.buttonCorner.layer.cornerRadius = 50
        cameraView?.groupContainerView.layer.cornerRadius = 18
        cameraView?.mapContainerView.layer.cornerRadius = 18
    }
    
    func setupGroupStackView() {
        groupStackView.delegate = self
        groupStackView.dataSource = self
        view.addSubview(groupStackView)
        groupStackView.translatesAutoresizingMaskIntoConstraints = false
        groupStackView.isHidden = true
        
        let numberOfButtons = CGFloat(groupIDs.count)
        let viewFrameWidth = CGFloat(view.frame.width)
        // 這邊是為了讓 button 的寬度在不同群組數都能維持一致，因此 StackView 需要依據 button 數量變化寬度所產生的算式
        let widthValue = CGFloat((((viewFrameWidth - 20) / 3 + 10) * numberOfButtons) - 10)
        
        NSLayoutConstraint.activate([
            groupStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            groupStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            groupStackView.heightAnchor.constraint(equalToConstant: 60),
            groupStackView.widthAnchor.constraint(equalToConstant: widthValue)
        ])
    }
    
    func createCamera() {
        guard let captureDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: currentCamera
        ) else { return }
        createCamera(captureDevice: captureDevice)
    }
    
    func createCamera(captureDevice: AVCaptureDevice) {
        // Set up capture session
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        // Set session preset
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }
        
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
            
            view.bringSubviewToFront(groupStackView)
        } catch {
            print("Error setting up capture device: \(error.localizedDescription)")
        }
    }
    
    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileReference = Storage.storage().reference().child(UUID().uuidString + ".jpg")
        if let data = image.jpegData(compressionQuality: 0.2) {
            fileReference.putData(data, metadata: nil) { result in
                switch result {
                case .success:
                    fileReference.downloadURL(completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func toggleCamera() {
        captureSession?.stopRunning()
        
        if currentCamera == .back {
            currentCamera = .front
        } else {
            currentCamera = .back
        }
        createCamera()
    }
}
