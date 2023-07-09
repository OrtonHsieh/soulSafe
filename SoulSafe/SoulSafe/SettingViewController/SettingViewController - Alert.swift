//
//  SettingViewController - Alert.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/9.
//

import UIKit

extension SettingViewController {
    func userLogOut() {
        let alertController = UIAlertController(title: "確認登出", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        
        let myPostAction = UIAlertAction(title: "確認", style: .default) { action in
            UserDefaults.standard.removeObject(forKey: "userID")
        }
        alertController.addAction(myPostAction)
        // 在這裡顯示 UIAlert
        // 例如：
        present(alertController, animated: true, completion: nil)
    }
}
