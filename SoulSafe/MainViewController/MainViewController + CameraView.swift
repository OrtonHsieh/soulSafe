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
                self.viewModel.didGetSuccessResponseWhenPressSendBtn(
                    url: url,
                    db: self.db,
                    selectedGroupDict: self.selectedGroupDict
                ) { [weak self] _ in
                    guard let self = self else { return }
                    // 這邊等 UI 切好也要一起傳到 group 裡的 post
                    self.cleanGroupSelection()
                    self.delegate?.didPressSendBtn(self)
                }
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
