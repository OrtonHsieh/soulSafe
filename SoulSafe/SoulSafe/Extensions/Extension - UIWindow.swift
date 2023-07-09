//
//  Extension - UIWindow.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/9.
//

import UIKit

extension UIWindow {
    var topViewController: UIViewController? {
        // 用遞迴的方式找到最後被呈現的 view controller。
        if var topVC = rootViewController {
            while let vc = topVC.presentedViewController {
                topVC = vc
            }
            return topVC
        } else {
            return nil
        }
    }
}
