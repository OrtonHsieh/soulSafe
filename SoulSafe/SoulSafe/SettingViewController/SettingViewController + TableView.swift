//
//  SettingViewController + TableView.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/8.
//

import UIKit

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)")
        if indexPath.row == 0 {
            DispatchQueue.main.async {
                self.showOptionsAlert(title: "注意！", message: "是否確認刪除帳號？", confirmInfo: "確認") { [weak self] in
                    guard let self = self else { return }
                    self.settingViewModel.deleteUserAccount { result in
                        switch result {
                        case .success:
                            self.showConfirmAlert(title: "系統訊息", message: "帳號已刪除", confirmInfo: "返回登入頁") {
                                UserDefaults.standard.removeObject(forKey: "userIDForAuth")
                                UserDefaults.standard.removeObject(forKey: "userID")
                                UserDefaults.standard.removeObject(forKey: "userName")
                                UserDefaults.standard.removeObject(forKey: "userAvatar")
                            }
                            print("Account deleted.")
                        case .failure(let error):
                            self.handleError(error)
                        }
                    }
                }
            }
        } else {
            showOptionsAlert(title: "確認登出", message: nil, confirmInfo: "確認") {
                UserDefaults.standard.removeObject(forKey: "userIDForAuth")
            }
        }
    }
    
    func handleError(_ error: SettingViewModel.AccountError) {
        switch error {
        case .upload:
            print("Failed to delete account from fireStore.")
        case .invalidToken:
            self.showOptionsAlert(title: "注意", message: "刪除前請再次重新登入", confirmInfo: "登出") {
                UserDefaults.standard.removeObject(forKey: "userIDForAuth")
            }
        }
    }
}

extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SettingTableViewCell",
            for: indexPath) as? SettingTableViewCell else {
            fatalError("Failed to produce reuseable cell for SettingTableViewCell.")
        }
        let settingTableViewTitleArray = ["刪除帳號", "登出"]
        cell.settingOptionLabel.text = settingTableViewTitleArray[indexPath.row]
        cell.layer.shadowColor = UIColor(red: 24 / 255, green: 183 / 255, blue: 231 / 255, alpha: 0.4).cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 8
        return cell
    }
}
