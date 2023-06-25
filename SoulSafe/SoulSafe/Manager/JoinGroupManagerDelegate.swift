//
//  JoinGroupManagerDelegate.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/25.
//

import UIKit

protocol JoinGroupManagerDelegate: AnyObject {
    func groupInfo(_ manager: JoinGroupManager, groupTitle: String, groupID: String)
    // 這邊要傳給需要的 VC, 需要的 VC 接收到後再 reloadData
}
