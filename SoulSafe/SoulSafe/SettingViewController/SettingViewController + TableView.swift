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
                self.deleteUserAccount()
            }
        } else {
            userLogOut()
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
