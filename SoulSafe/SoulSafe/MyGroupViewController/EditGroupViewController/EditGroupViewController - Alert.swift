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

protocol EditGroupViewControllerDelegate: AnyObject {
    func didCreateNewGroup(_ VC: EditGroupViewController, groupsTitle: [String])
}

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
        let submitAction = UIAlertAction(title: "确定", style: .default) { _ in
            if let textField = alertController.textFields?.first {
                if let inputText = textField.text {
                    let groupPath =  self.db.collection("testingUploadImg").document("userIDOrton").collection("groups").document()
                    groupPath.setData([
                        "groupID": "\(groupPath.documentID)",
                        "groupTitle": "\(inputText)",
                        "timeStamp": Timestamp(date: Date())
                    ])
                    self.groupID = groupPath.documentID
                    self.groupTitle.append(inputText)
                    self.editGroupTBView.reloadData()
                    self.delegate?.didCreateNewGroup(self, groupsTitle: self.groupTitle)
                }
            }
        }
        alertController.addAction(submitAction)

        // 顯示 Alert
        viewController.present(alertController, animated: true, completion: nil)
    }
}
