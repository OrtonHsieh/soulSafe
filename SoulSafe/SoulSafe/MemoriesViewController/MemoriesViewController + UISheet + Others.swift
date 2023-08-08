//
//  MemoriesViewController + UISheet + Others.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/8.
//

import UIKit

extension MemoriesViewController: UISheetPresentationControllerDelegate {
    func presentPostViewController(_ imageURL: String, postID: String, groupIDArray: [String], groupTitleArray: [String]) {
        let postVC = PostViewController()
        postVC.modalPresentationStyle = .formSheet
        let url = URL(string: imageURL)
        postVC.imageView.kf.setImage(with: url)
        postVC.currentPostID = postID
        // 這邊目前 Post 點進去時會是上一張照片
        postVC.selectedGroup = selectedGroup
        postVC.selectedGroupTitle = selectedGroupTitle
        postVC.selectedGroupInPostVC = selectedGroup
        postVC.groupIDArray = groupIDArray
        postVC.groupTitleArray = groupTitleArray
        Vibration.shared.lightV()
        present(postVC, animated: true)
        
        if let sheetPC = postVC.sheetPresentationController {
            sheetPC.detents = [.large()]
            sheetPC.prefersGrabberVisible = true
            sheetPC.delegate = self
            sheetPC.preferredCornerRadius = 20
        }
    }
}

extension MemoriesViewController: MemoriesViewDelegate {
    func didPressGroupSelector(_ view: MemoriesView) {
        showGroupList(groupTitles)
    }
    
    func didPressBackBtn(_ view: MemoriesView) {
        delegate?.didPressBackBtn(self)
    }
}
