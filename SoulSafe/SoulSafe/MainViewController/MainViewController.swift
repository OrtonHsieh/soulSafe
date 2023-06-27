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
    func didSentImg(_ mainVC: MainViewController, postID: String)
}

class MainViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var cameraView: CameraView?
    weak var delegate: MainViewControllerDelegate?
    var joinGroupManager: JoinGroupManager?
    // swiftlint:disable all
    let db = Firestore.firestore()
    // swiftlint:enable all
    var groupTitles: [String] = []
    var groupIDs: [String] = []
    let groupVC = GroupViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: CIC.shared.M1)
//        groupVC.delegate = self
        createCamera()
        getGroupData()
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
        
        uploadPhoto(image: image) { result in
            switch result {
            case .success(let url):
                print(url)
                // 上傳資料
                let postPath = self.db.collection("testingUploadImg").document("\(UserSetup.userID)").collection("posts").document()
                
                postPath.setData([
                    "postImgURL": "\(url)",
                    "postID": "\(postPath.documentID)",
                    "timeStamp": Timestamp(date: Date())
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                // 把資料傳給 BaseVC
                self.delegate?.didSentImg(self, postID: postPath.documentID)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func didPressGroupBtn(_ view: CameraView) {
        groupVC.modalPresentationStyle = .formSheet
        groupVC.groupTitles = groupTitles
        groupVC.groupIDs = groupIDs
        Vibration.shared.lightV()
        
        let navigationController = UINavigationController(rootViewController: groupVC)
        navigationController.modalPresentationStyle = .formSheet
        
        if let sheetPC = navigationController.presentationController as? UISheetPresentationController {
            sheetPC.detents = [.medium()]
            sheetPC.prefersGrabberVisible = true
            sheetPC.delegate = self
            sheetPC.preferredCornerRadius = 20
        }
        
        view.window?.rootViewController?.present(navigationController, animated: true)
    }
    
//    func listenToGroupData() {
//        let groupsPath = db.collection("groups").whereField("members", arrayContains: "\(UserSetup.userID)")
//
////        groupsPath
//        // 等等回來繼續用這邊，要先在建立群組時於 doc 加入 userID
//
//        groupsPath.order(by: "timeStamp", descending: true).addSnapshotListener { querySnapshot, error in
//            if let error = error {
//                print("Error fetching collection: \(error)")
//                return
//            }
//
//            guard let documents = querySnapshot?.documents else {
//                print("No documents in collection")
//                return
//            }
//
//            var index = 0
//
//            for document in documents {
//                let data = document.data()
//                guard let groupID = data["groupID"] as? String else { return }
//                guard let groupTitle = data["groupTitle"] as? String else { return }
//
//                if index <= self.groupIDs.count - 1 {
//                    self.groupIDs[index] = groupID
//                    self.groupTitles[index] = groupTitle
//                } else {
//                    self.groupIDs.append(groupID)
//                    self.groupTitles.append(groupTitle)
//                }
//                index += 1
//            }
//            self.groupVC.groupTitles = self.groupTitles
//            self.groupVC.groupIDs = self.groupIDs
//            self.groupVC.groupTableView.reloadData()
//            self.groupVC.updateEditGroupVC()
//        }
//    }
    
    func getGroupData() {
        let groupsPath = self.db.collection(
            "testingUploadImg"
        ).document(
            "\(UserSetup.userID)"
        ).collection(
            "groups"
        )
        
        groupsPath.order(by: "timeStamp", descending: true).addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
//                var index = 0
                self.groupIDs.removeAll()
                self.groupTitles.removeAll()
                guard let querySnapshot = querySnapshot else { return }
                for document in querySnapshot.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    guard let groupTitle = data["groupTitle"] as? String else { return }
                    guard let groupID = data["groupID"] as? String else { return }
                    
//                    if index <= self.groupTitles.count - 1 {
//                        self.groupTitles[index] = groupTitle
//                        self.groupIDs[index] = groupID
//                    } else {
//                        self.groupTitles.append(groupTitle)
//                        self.groupIDs.append(groupID)
//                    }
//                    index += 1
                    self.groupIDs.append(groupID)
                    self.groupTitles.append(groupTitle)
                }
                print(self.groupTitles)
                print(self.groupIDs)
                self.groupVC.groupTitles = self.groupTitles
                self.groupVC.groupIDs = self.groupIDs
                self.groupVC.groupTableView.reloadData()
                self.groupVC.updateEditGroupVC()
            }
        }
    }
}

extension MainViewController: UISheetPresentationControllerDelegate {
}

//extension MainViewController: GroupViewControllerDelegate {
//    func didReceiveNewGroup(_ VC: GroupViewController, newGroupIDs: [String], newGroupsTitle: [String]) {
//        groupTitles = newGroupsTitle
//        groupIDs = newGroupIDs
////        getGroupData()
//    }
//
//    func didRemoveGroup(_ VC: GroupViewController, newGroupIDs: [String], newGroupsTitle: [String]) {
//        groupIDs = newGroupIDs
//        groupTitles = newGroupsTitle
////        getGroupData()
//    }
//}
