//
//  SettingViewController - Alert.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/9.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import FirebaseFirestore

extension SettingViewController {
    func userLogOut() {
        let alertController = UIAlertController(title: "確認登出", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        
        let myPostAction = UIAlertAction(title: "確認", style: .default) { action in
            UserDefaults.standard.removeObject(forKey: "userIDForAuth")
        }
        alertController.addAction(myPostAction)
        // 在這裡顯示 UIAlert
        // 例如：
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteUserAccount() {
        let alertController = UIAlertController(title: "注意！", message: "是否確認刪除帳號？", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        
        let myPostAction = UIAlertAction(title: "確認", style: .default) { action in
            let user = Auth.auth().currentUser
            
            user?.delete { error in
                if let error = error {
                    print("Failed to delete user account: \(error)")
                    let alertController = UIAlertController(title: "注意", message: "刪除前請再次重新登入", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel)
                    alertController.addAction(cancelAction)
                    
                    let myPostAction = UIAlertAction(title: "登出", style: .default) { action in
                        UserDefaults.standard.removeObject(forKey: "userIDForAuth")
                    }
                    alertController.addAction(myPostAction)
                    // 在這裡顯示 UIAlert
                    // 例如：
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
                    // 先刪掉 group 再刪掉 post 最後刪掉 document 路徑
                    let accountDeletePath = self.db.collection("users").document("\(userID)")
                    accountDeletePath.delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            self.confirmAccountDeletion()
                            print("Account deleted.")
                        }
                    }
                }
            }
        }
        alertController.addAction(myPostAction)
        // 在這裡顯示 UIAlert
        // 例如：
        present(alertController, animated: true, completion: nil)
    }
    
    func confirmAccountDeletion() {
        let alertController = UIAlertController(title: "系統訊息", message: "帳號已刪除", preferredStyle: .alert)
        
        let myPostAction = UIAlertAction(title: "返回登入頁", style: .default) { _ in
            UserDefaults.standard.removeObject(forKey: "userIDForAuth")
        }
        alertController.addAction(myPostAction)
        // 在這裡顯示 UIAlert
        // 例如：
        present(alertController, animated: true, completion: nil)
    }
    
    func commingSoonAlert() {
        let alertController = UIAlertController(title: "敬請期待新功能", message: nil, preferredStyle: .alert)
        
        let confirmBtn = UIAlertAction(title: "好！", style: .default)
        alertController.addAction(confirmBtn)
        // 在這裡顯示 UIAlert
        // 例如：
        present(alertController, animated: true, completion: nil)
    }
}
