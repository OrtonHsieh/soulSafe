//
//  Extension - Alert.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/22.
//

import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

extension EditGroupViewController {
    func inputAlertForCreateGroup(from viewController: UIViewController) {
        let alertController = UIAlertController(title: "創立群組", message: "請輸入群組名稱", preferredStyle: .alert)
        
        // placeHolder
        alertController.addTextField { textField in
            textField.placeholder = "我的群組名稱"
        }
        
        // 取消按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // 確定按鈕
        let submitAction = UIAlertAction(title: "確認", style: .default) { _ in
            if let textField = alertController.textFields?.first {
                if let inputText = textField.text {
                    // 將資料建立在 user 集合該創立者下的 group 集合
                    let groupPath =  self.db.collection("users").document("\(UserSetup.userID)").collection("groups").document()
                    groupPath.setData([
                        "groupID": "\(groupPath.documentID)",
                        "groupTitle": "\(inputText)",
                        "timeStamp": Timestamp(date: Date())
                    ])
                    // 將資料同步儲存到 groups 集合下
                    let initGroupPath = self.db.collection("groups").document("\(groupPath.documentID)")
                    initGroupPath.setData([
                        "groupID": "\(groupPath.documentID)",
                        "groupTitle": "\(inputText)",
                        "members": [
                            "\(UserSetup.userID)"
                        ],
                        "timeStamp": Timestamp(date: Date())
                    ])
                    guard let avatar = UserDefaults.standard.object(forKey: "userAvatar") else { return }
                    initGroupPath.collection("members").document("\(UserSetup.userID)").setData([
                        "userID": "\(UserSetup.userID)",
                        "joinedTime": Timestamp(date: Date()),
                        "userAvatar": "\(avatar)"
                    ])
                    
                    self.currentGroupID = groupPath.documentID
                    self.groupLink = "soulsafe.app.link.page://\(self.currentGroupID)"
                    
                    let activityViewController = UIActivityViewController(activityItems: [self.groupLink], applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                }
            }
        }
        alertController.addAction(submitAction)
        
        // 顯示 Alert
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func leaveAlert(from viewController: UIViewController) {
        let alertController = UIAlertController(title: "退出群組", message: "是否忍痛退出ＱＱ？", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        print("我是\(currentGroupID)")
        let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
//            let groupPath =  self.db.collection("testingUploadImg").document("\(UserSetup.userID)").collection("groups").document("\(self.currentGroupID)")
            let groupPath =  self.db.collection("users").document("\(UserSetup.userID)").collection("groups").document("\(self.currentGroupID)")
            groupPath.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("成功於 fireStore 將群組由個人的群組路徑移除")
                    
                    let initGroupPath = self.db.collection("groups").document("\(self.currentGroupID)").collection("members").document("\(UserSetup.userID)")
                    initGroupPath.delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("成功於 fireStore 將群組由群組的路徑移除個人資料")
                        }
                    }
                    
                    // 更新 groupID 到當前 local data 第一個 group
                    if self.groupIDs.count >= 1 {
                        guard let firstGroupID = self.groupIDs.first else { return }
                        self.currentGroupID = firstGroupID
                    }
                    print("Document successfully removed!")
                }
            }
        }
        alertController.addAction(confirmAction)
        
        viewController.present(alertController, animated: true)
    }
    
    // 確認入群後會顯示確認訊息
    func copiedLinkMsg(from viewController: UIViewController) {
        let alertController = UIAlertController(title: "已複製連結", message: "快去分享給朋友吧！", preferredStyle: .alert)

        let confirmButton = UIAlertAction(title: "確認", style: .default)
        alertController.addAction(confirmButton)

        // 在這裡顯示 UIAlert
        // 例如：
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func commingSoonAlert() {
        let alertController = UIAlertController(title: "敬請期待新功能", message: nil, preferredStyle: .alert)
        
        let confirmBtn = UIAlertAction(title: "好！", style: .default)
        alertController.addAction(confirmBtn)
        // 在這裡顯示 UIAlert
        // 例如：
        present(alertController, animated: true, completion: nil)
    }
    
    func reachGroupsLimit() {
        let alertController = UIAlertController(title: "系統訊息", message: "已達群組上線", preferredStyle: .alert)
        
        let confirmBtn = UIAlertAction(title: "好吧！", style: .default)
        alertController.addAction(confirmBtn)
        // 在這裡顯示 UIAlert
        // 例如：
        present(alertController, animated: true, completion: nil)
    }
}
