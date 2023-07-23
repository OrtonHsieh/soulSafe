//
//  MainViewController - Extension.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/22.
//

import AVFoundation
import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

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

extension MainViewController: CameraViewDelegate {
    func didPressSettingBtn(_ view: CameraView) {
        Vibration.shared.lightV()
        delegate?.didPressSettingBtn(self)
    }
    
    func didPressMemoriesBtn(_ view: CameraView) {
        Vibration.shared.lightV()
        delegate?.didPressMemoriesBtn(self)
    }
    
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
            let alertController = UIAlertController(
                title: "尚未加入群組",
                message: "快去跟朋友創建群組再回來看看吧！",
                preferredStyle: .alert
            )
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
        cameraView?.reverseButton.isHidden = false
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
        cameraView?.reverseButton.isHidden = true
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
                let postPath = self.db.collection("users").document("\(UserSetup.userID)").collection("posts").document()
                // 原本 selectedGroupDict 裡面有 UIButton 以及 GroupID 跟 UIButton，這邊先用 compactMap 將 String 以外的型別過濾掉，再用 FlatMap 將所有 Key 的 String 值整合在一個 Array 裏
                let groupArray = self.selectedGroupDict.flatMap {
                    $0.value.compactMap {
                        $0 as? String
                    }
                }
                let groupIDArray = groupArray.enumerated().compactMap { index, element -> String? in
                    if index % 2 == 0 {
                        return element
                    } else {
                        return nil
                    }
                }
                let groupTitleArray = groupArray.enumerated().compactMap { index, element -> String? in
                    if index % 2 != 0 {
                        return element
                    } else {
                        return nil
                    }
                }
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
    
    func didPressReverseBtn(_ view: CameraView) {
        Vibration.shared.lightV()
        cameraView?.removeFromSuperview()
        toggleCamera()
        UIView.animate(withDuration: 0.3, animations: {
            // Rotate the button 180 degrees (π radians) around the y-axis
            self.cameraView?.reverseButton.transform = self.cameraView?.reverseButton.transform.rotated(
                by: CGFloat.pi
            ) ?? CGAffineTransform.identity
        }, completion: { _ in
            print("rotated.")
        })
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
