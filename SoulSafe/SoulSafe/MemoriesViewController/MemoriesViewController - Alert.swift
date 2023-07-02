//
//  MemoriesViewController - Alert.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/29.
//

import UIKit

extension MemoriesViewController {
    func showGroupList(_ groupTitles: [String]) {
        let alertController = UIAlertController(title: "選擇群組", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        
        let myPostAction = UIAlertAction(title: "我的貼文", style: .default) { action in
            self.selectedGroup = ""
            self.galleryCollection.reloadData()
            self.memoriesView.groupSelectorLabel.text = "我的貼文"
            self.ifGroupViewTextIsMyPost = true
        }
        alertController.addAction(myPostAction)
        
        for (index, groupTitle) in groupTitles.enumerated() {
            let action = UIAlertAction(title: "\(groupTitle)", style: .default) { action in
                self.selectedGroup = self.groupIDs[index]
                self.selectedGroupTitle = self.groupTitles[index]
                self.galleryCollection.reloadData()
                self.memoriesView.groupSelectorLabel.text = groupTitle
                self.ifGroupViewTextIsMyPost = false
            }
            alertController.addAction(action)
        }
        // 在這裡顯示 UIAlert
        // 例如：
        present(alertController, animated: true, completion: nil)
    }
}
