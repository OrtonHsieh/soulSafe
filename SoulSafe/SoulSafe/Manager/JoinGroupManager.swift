//
//  JoinGroupManager.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/25.
//

import UIKit
import FirebaseFirestore

class JoinGroupManager {
    let db = Firestore.firestore()
    let viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func getJoinGroupInfo(_ groupID: String) {
        // 拿取 group 資料
        // pop 是否加入 Alert 是的話再呼叫 Delegate，否就 dismiss
        var userIDs: [String] = []
        let joinGroupPath = db.collection("groups").document("\(groupID)")
        let members = joinGroupPath.collection("members")
        
        members.getDocuments { documents, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var index = 0
                guard let documents = documents else { return }
                for document in documents.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    guard let userID = data["userID"] as? String else { return }
                    
                    if userID != UserSetup.userID {
                        userIDs.append(userID)
                    } else {
                        // 跳 Alert 顯示已加入過群組
                        self.showRemindAlert()
                        break
                    }
                    index += 1
                }
                print(userIDs)
                joinGroupPath.getDocument  { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        print("Document data: \(dataDescription)")
                        guard let data = document.data() else { return }
                        guard let groupID = data["groupID"] as? String else { return }
                        let joinGroupID = groupID
                        guard let groupTitle = data["groupTitle"] as? String else { return }
                        let joinGroupTitle = groupTitle
                        self.showConfirmAlert(joinGroupID, joinGroupTitle)
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
    // 確認入群的詢問畫面
    private func showConfirmAlert(_ groupID: String, _ groupTitle: String) {
        let alertController = UIAlertController(title: "確認加入群組", message: "加入\(groupTitle)", preferredStyle: .alert)

        let rejectButton = UIAlertAction(title: "取消", style: .cancel)

        let confirmButton = UIAlertAction(title: "確認", style: .default) { (action) in
            let didJoinGroupPath = self.db.collection("groups").document("\(groupID)").collection("members").document("\(UserSetup.userID)")
            
//            let addGroupToUser = self.db.collection("testingUploadImg").document("\(UserSetup.userID)").collection("groups").document("\(groupID)")
            let addGroupToUser = self.db.collection("users").document("\(UserSetup.userID)").collection("groups").document("\(groupID)")
            
            didJoinGroupPath.setData([
                "userID": "\(UserSetup.userID)",
                "joinedTime": Timestamp(date: Date())
            ])
            
            self.db.collection("groups").document("\(groupID)").updateData([
                "members": FieldValue.arrayUnion(["\(UserSetup.userID)"])
            ])
            
            addGroupToUser.setData([
                "groupID": "\(groupID)",
                "groupTitle": "\(groupTitle)",
                "timeStamp": Timestamp(date: Date())
            ])
            
            self.joinedSuccessfullyMsg(groupTitle)
            print("傳訊息給相關的 VC")
        }

        alertController.addAction(rejectButton)
        alertController.addAction(confirmButton)

        // 在這裡顯示 UIAlert
        // 例如：
        guard let viewController = viewController else { return }
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    // 判斷已經加入過群組會顯示的訊息
    private func showRemindAlert() {
        let alertController = UIAlertController(title: "注意", message: "您已加入群組，快去聊天吧！", preferredStyle: .alert)

        let confirmButton = UIAlertAction(title: "確認", style: .default)
        alertController.addAction(confirmButton)

        // 在這裡顯示 UIAlert
        // 例如：
        guard let viewController = viewController else { return }
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    // 確認入群後會顯示確認訊息
    func joinedSuccessfullyMsg(_ groupTitle: String) {
        let alertController = UIAlertController(title: "成功加入", message: "您已加入\(groupTitle)，快去聊天吧！", preferredStyle: .alert)

        let confirmButton = UIAlertAction(title: "確認", style: .default)
        alertController.addAction(confirmButton)

        // 在這裡顯示 UIAlert
        // 例如：
        guard let viewController = viewController else { return }
        viewController.present(alertController, animated: true, completion: nil)
    }
}
