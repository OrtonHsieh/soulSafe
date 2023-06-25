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
                    let groupPath =  self.db.collection("testingUploadImg").document("\(UserSetup.userID)").collection("groups").document()
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
                    initGroupPath.collection("members").document("\(UserSetup.userID)").setData([
                        "userID": "\(UserSetup.userID)",
                        "joinedTime": Timestamp(date: Date())
                    ])
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
            let groupPath =  self.db.collection("testingUploadImg").document("\(UserSetup.userID)").collection("groups").document("\(self.currentGroupID)")
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
}
