//
//  MainViewController + GroupSelcetion.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/8.
//

import UIKit

extension MainViewController: GroupSelectionStackViewDelegate {
    func groupSelectionStackView(_ view: GroupSelectionStackView, didSelectButton button: UIButton) {
        Vibration.shared.lightV()
        if button.layer.borderWidth == 0 {
            // 如果原本寬度為 0 代表未被選擇，讓寬度變 1 表示選擇
            button.layer.borderWidth = 1
            // 將選擇的按鈕 groupID 加入 Dict 方便上傳時取用 ID 上傳
            selectedGroupDict["\(groupIDs[button.tag])"] = [groupIDs[button.tag], button, groupTitles[button.tag]]
        } else {
            // 如果原本寬度為 1 代表已被選擇，讓寬度變 0 表示取消選擇
            button.layer.borderWidth = 0
            selectedGroupDict.removeValue(forKey: "\(groupIDs[button.tag])")
        }
    }
}

extension MainViewController: GroupSelectionStackViewDataSource {
    func numberOfButtons(in view: GroupSelectionStackView) -> Int {
        groupIDs.count
    }
    
    func titleForButtons(at index: Int, in view: GroupSelectionStackView) -> String {
        groupTitles[index]
    }
}
