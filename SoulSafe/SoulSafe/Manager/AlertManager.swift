//
//  AlertManager.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AlertManager {
    static let shared = AlertManager()
    
    private init() {}
    // swiftlint:disable all
    let db = Firestore.firestore()
    // swiftlint:enable all
    
    typealias ImagePickerAndNaviControllerDelegate = UIImagePickerControllerDelegate & UINavigationControllerDelegate
    
    func userLogOut(viewController settingViewController: UIViewController) {
        let alertController = UIAlertController(title: "確認登出", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        
        let myPostAction = UIAlertAction(title: "確認", style: .default) { _ in
            UserDefaults.standard.removeObject(forKey: "userIDForAuth")
        }
        alertController.addAction(myPostAction)
        // 在這裡顯示 UIAlert
        // 例如：
        settingViewController.present(alertController, animated: true, completion: nil)
    }
    
    func deleteUserAccount(viewController settingViewController: UIViewController) {
        let alertController = UIAlertController(title: "注意！", message: "是否確認刪除帳號？", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        
        let myPostAction = UIAlertAction(title: "確認", style: .default) { _ in
            let user = Auth.auth().currentUser
            
            user?.delete { error in
                if let error = error {
                    print("Failed to delete user account: \(error)")
                    let alertController = UIAlertController(title: "注意", message: "刪除前請再次重新登入", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel)
                    alertController.addAction(cancelAction)
                    
                    let myPostAction = UIAlertAction(title: "登出", style: .default) { _ in
                        UserDefaults.standard.removeObject(forKey: "userIDForAuth")
                    }
                    alertController.addAction(myPostAction)
                    // 在這裡顯示 UIAlert
                    // 例如：
                    settingViewController.present(alertController, animated: true, completion: nil)
                } else {
                    guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
                    // 先刪掉 group 再刪掉 post 最後刪掉 document 路徑
                    let accountDeletePath = self.db.collection("users").document("\(userID)")
                    accountDeletePath.delete { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            self.confirmAccountDeletion(viewController: settingViewController)
                            print("Account deleted.")
                        }
                    }
                }
            }
        }
        alertController.addAction(myPostAction)
        // 在這裡顯示 UIAlert
        // 例如：
        settingViewController.present(alertController, animated: true, completion: nil)
    }
    
    func confirmAccountDeletion(viewController settingViewController: UIViewController) {
        let alertController = UIAlertController(title: "系統訊息", message: "帳號已刪除", preferredStyle: .alert)
        
        let myPostAction = UIAlertAction(title: "返回登入頁", style: .default) { _ in
            UserDefaults.standard.removeObject(forKey: "userIDForAuth")
            UserDefaults.standard.removeObject(forKey: "userID")
            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "userAvatar")
        }
        alertController.addAction(myPostAction)
        // 在這裡顯示 UIAlert
        // 例如：
        settingViewController.present(alertController, animated: true, completion: nil)
    }
    
    func commingSoonAlert(viewController: UIViewController) {
        let alertController = UIAlertController(title: "敬請期待新功能", message: nil, preferredStyle: .alert)
        
        let confirmBtn = UIAlertAction(title: "好！", style: .default)
        alertController.addAction(confirmBtn)
        // 在這裡顯示 UIAlert
        // 例如：
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func reachGroupsLimit(viewController: UIViewController) {
        let alertController = UIAlertController(title: "系統訊息", message: "已達群組上線", preferredStyle: .alert)
        
        let confirmBtn = UIAlertAction(title: "好吧！", style: .default)
        alertController.addAction(confirmBtn)
        // 在這裡顯示 UIAlert
        // 例如：
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func chooseImageAlert(viewController settingViewController: UIViewController) {
        let alert = UIAlertController(title: "選擇照片來源", message: nil, preferredStyle: .actionSheet)
        
        let dismissAlert = UIAlertAction(title: "關閉", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        
        let galleryAction = UIAlertAction(title: "從相簿選擇", style: .default) { _ in
            let picController = UIImagePickerController()
            picController.sourceType = .photoLibrary
            picController.delegate = settingViewController as? any ImagePickerAndNaviControllerDelegate
            settingViewController.present(picController, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "開啟相機", style: .default) { _ in
            let picController = UIImagePickerController()
            picController.sourceType = .camera
            picController.delegate = settingViewController as? any ImagePickerAndNaviControllerDelegate
            settingViewController.present(picController, animated: true, completion: nil)
        }
        
        alert.addAction(dismissAlert)
        alert.addAction(galleryAction)
        alert.addAction(cameraAction)
        
        settingViewController.present(alert, animated: true, completion: nil)
    }
}
