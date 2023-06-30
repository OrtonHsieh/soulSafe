//
//  PostViewController - Alert.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/30.
//

import UIKit

extension PostViewController {
    // 這個 alert 主要是給
    func showGroupList(_ groupTitles: [String]) {
        let alertController = UIAlertController(title: "選擇群組", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        
        for (index, groupTitle) in groupTitles.enumerated() {
            let action = UIAlertAction(title: "\(groupTitle)", style: .default) { action in
                self.selectedGroupForPost = self.groupIDArray[index]
                self.selectedGroupTitleForPost = self.groupTitleArray[index]
                self.postTableView.reloadData()
            }
            alertController.addAction(action)
        }
        // 在這裡顯示 UIAlert
        // 例如：
        present(alertController, animated: true, completion: nil)
    }
}
