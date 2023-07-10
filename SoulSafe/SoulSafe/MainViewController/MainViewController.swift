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
//        groupVC.delegate = self
        createCamera()
        getGroupData()
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
            groupStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            groupStackView.heightAnchor.constraint(equalToConstant: 60),
            groupStackView.widthAnchor.constraint(equalToConstant: widthValue)
        ])
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
            
            conponentsArrangementWhenCameraOff()
        }
    }
}

extension MainViewController: CameraViewDelegate {
    func didPressMapBtn(_ view: CameraView) {
        // 推出 MapView
        if !groupIDs.isEmpty {
            mapViewController.modalPresentationStyle = .fullScreen
            mapViewController.groupTitles = groupTitles
            mapViewController.groupIDs = groupIDs
            mapViewController.isInitialized = true
            Vibration.shared.lightV()
            present(mapViewController, animated: true)
        } else {
            let alertController = UIAlertController(title: "尚未加入群組", message: "快去跟朋友創建群組再回來看看吧！", preferredStyle: .alert)
            
            let confirmAlert = UIAlertAction(title: "確認", style: .default)
            alertController.addAction(confirmAlert)
            // 在這裡顯示 UIAlert
            // 例如：
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func didTakePic(_ view: CameraView) {
        guard let photoOutput = self.photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func conponentsArrangementWhenCameraOn() {
        cameraView?.photoImageView.isHidden = true
        cameraView?.cameraView.isHidden = false
        cameraView?.closeButton.isHidden = true
        cameraView?.buttonCorner.isHidden = false
        cameraView?.picButton.isHidden = false
        cameraView?.sendButton.isHidden = true
        cameraView?.groupContainerView.isHidden = false
        groupStackView.isHidden = true
    }
    
    func conponentsArrangementWhenCameraOff() {
        cameraView?.photoImageView.isHidden = false
        cameraView?.cameraView.isHidden = true
        cameraView?.closeButton.isHidden = false
        cameraView?.buttonCorner.isHidden = true
        cameraView?.picButton.isHidden = true
        cameraView?.sendButton.isHidden = false
        cameraView?.groupContainerView.isHidden = true
        groupStackView.isHidden = false
    }
    
    func didPressCloseBtn(_ view: CameraView) {
        Vibration.shared.mediumV()
        conponentsArrangementWhenCameraOn()
        cleanGroupSelection()
    }
    
    func didPressSendBtn(_ view: CameraView, image: UIImage) {
        Vibration.shared.lightV()
        conponentsArrangementWhenCameraOn()
        
        uploadPhoto(image: image) { result in
            switch result {
            case .success(let url):
                print(url)
                // 上傳資料
//                let postPath = self.db.collection("testingUploadImg").document("\(UserSetup.userID)").collection("posts").document()
                let postPath = self.db.collection("users").document("\(UserSetup.userID)").collection("posts").document()
                // 原本 selectedGroupDict 裡面有 UIButton 以及 GroupID 跟 UIButton，這邊先用 compactMap 將 String 以外的型別過濾掉，再用 FlatMap 將所有 Key 的 String 值整合在一個 Array 裏
                let groupArray = self.selectedGroupDict.flatMap{ $0.value.compactMap{ $0 as? String }}
                let groupIDArray = groupArray.enumerated().compactMap {(index, element) -> String? in
                    if index % 2 == 0 {
                        return element
                    } else {
                        return nil
                    }
                }
                print(groupIDArray)
                let groupTitleArray = groupArray.enumerated().compactMap {(index, element) -> String? in
                    if index % 2 != 0 {
                        return element
                    } else {
                        return nil
                    }
                }
                print(groupTitleArray)
                postPath.setData([
                    "postImgURL": "\(url)",
                    "postID": "\(postPath.documentID)",
                    "timeStamp": Timestamp(date: Date()),
                    "shareGroupList": groupIDArray,
                    "groupTitleArray": groupTitleArray
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                
                for groupID in 0..<groupIDArray.count {
                    let groupPostPath = self.db.collection("groups").document("\(groupIDArray[groupID])").collection("posts").document("\(postPath.documentID)")
                    groupPostPath.setData([
                        "postID": "\(postPath.documentID)",
                        "postImgURL": "\(url)",
                        "timeStamp": Timestamp(date: Date()),
                        "shareGroupList": groupIDArray,
                        "groupTitleArray": groupTitleArray
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                } 
                // 這邊等 UI 切好也要一起傳到 group 裡的 post
                self.cleanGroupSelection()
                self.delegate?.didPressSendBtn(self)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func cleanGroupSelection() {
        for (_, group) in selectedGroupDict {
            for button in group {
                if let button = button as? UIButton {
                    button.layer.borderWidth = 0
                }
            }
        }
        selectedGroupDict.removeAll()
    }
    
    func didPressGroupBtn(_ view: CameraView) {
        groupVC.modalPresentationStyle = .formSheet
        groupVC.groupTitles = groupTitles
        groupVC.groupIDs = groupIDs
        Vibration.shared.lightV()
        
//        let navigationController = UINavigationController(rootViewController: groupVC)
//        navigationController.modalPresentationStyle = .formSheet
//
//        if let sheetPC = navigationController.presentationController as? UISheetPresentationController {
//            sheetPC.detents = [.medium()]
//            sheetPC.prefersGrabberVisible = true
//            sheetPC.delegate = self
//            sheetPC.preferredCornerRadius = 20
//        }
//
//        view.window?.rootViewController?.present(navigationController, animated: true)
        
        let navigationController = UINavigationController(rootViewController: groupVC)
        navigationController.modalPresentationStyle = .formSheet

        if let sheetPC = navigationController.presentationController as? UISheetPresentationController {
            sheetPC.detents = [.medium()]
            sheetPC.prefersGrabberVisible = true
            sheetPC.delegate = self
            sheetPC.preferredCornerRadius = 20
        }

        present(navigationController, animated: true, completion: nil)
    }
    
    func getGroupData() {
//        let groupsPath = self.db.collection("testingUploadImg").document("\(UserSetup.userID)").collection("groups")
        let groupsPath = self.db.collection("users").document("\(UserSetup.userID)").collection("groups")
        
        groupsPath.order(by: "timeStamp", descending: true).addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.groupIDs.removeAll()
                self.groupTitles.removeAll()
                guard let querySnapshot = querySnapshot else { return }
                for document in querySnapshot.documents {
                    let data = document.data()
                    guard let groupTitle = data["groupTitle"] as? String else { return }
                    guard let groupID = data["groupID"] as? String else { return }
                    
                    self.groupIDs.append(groupID)
                    self.groupTitles.append(groupTitle)
                }
                self.groupVC.groupTitles = self.groupTitles
                self.groupVC.groupIDs = self.groupIDs
                self.groupVC.groupTableView.reloadData()
                self.groupVC.updateEditGroupVC()
                
                self.setupGroupStackView()
            }
        }
    }
}

extension MainViewController: UISheetPresentationControllerDelegate {
}

extension MainViewController: GroupSelectionStackViewDelegate {
    func groupSelectionStackView(_ view: GroupSelectionStackView, didSelectButton button: UIButton) {
        Vibration.shared.lightV()
        if button.layer.borderWidth == 0 {
            // 如果原本寬度為 0 代表未被選擇，讓寬度變 1 表示選擇
            button.layer.borderWidth = 1
            // 將選擇的按鈕 groupID 加入 Dict 方便上傳時取用 ID 上傳
            selectedGroupDict["\(groupIDs[button.tag])"] = [groupIDs[button.tag], button, groupTitles[button.tag]]
        } else {
            // 如果原本寬度為 1 代表已被選擇，讓寬度變 0 表示取消選擇
            button.layer.borderWidth = 0
            selectedGroupDict.removeValue(forKey: "\(groupIDs[button.tag])")
        }
    }
}

extension MainViewController: GroupSelectionStackViewDataSource {
    func numberOfButtons(in view: GroupSelectionStackView) -> Int {
        groupIDs.count
    }
    
    func titleForButtons(at index: Int, in view: GroupSelectionStackView) -> String {
        groupTitles[index]
    }
}
