//
//  MainViewModel.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/8.
//

import Foundation
import FirebaseFirestore

class MainViewModel {
    let dispatchGroup = DispatchGroup()
    
    func didGetSuccessResponseWhenPressSendBtn(
        url: (URL),
        // swiftlint:disable all
        db: Firestore,
        // swiftlint:enable all
        selectedGroupDict: [String: [Any]],
        conpletion: @escaping (Bool) -> Void
    ) {
        let userPath = db.collection("users")
        let postPath = userPath.document("\(UserSetup.userID)").collection("posts").document()
        // 原本 selectedGroupDict 裡面有 UIButton 以及 GroupID 跟 UIButton，這邊先用 compactMap 將 String 以外的型別過濾掉，再用 FlatMap 將所有 Key 的 String 值整合在一個 Array 裏
        let groupArray = selectedGroupDict.flatMap {
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
        dispatchGroup.enter()
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
                self.dispatchGroup.leave()
                print("Document successfully written!")
            }
        }
        for groupID in 0..<groupIDArray.count {
            dispatchGroup.enter()
            let groupPath = db.collection("groups")
            let groupPathToPosts = groupPath.document("\(groupIDArray[groupID])").collection("posts")
            let groupPostPath = groupPathToPosts.document("\(postPath.documentID)")
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
                    self.dispatchGroup.leave()
                    print("Document successfully written!")
                }
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            conpletion(true)
        }
    }
}
