//
//  Extension - UIColor.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/15.
//

import UIKit

// dependency injection 取代 singleton

// swiftlint:disable identifier_name
class CIC {
    static let shared = CIC()
    
    private init() {}
    
    let M1 = "081F39"
    let M2 = "0C3855"
    let M3 = "0E4665"
    let F1 = "50BFDB"
    let F2 = "7BD9F1"
}
// swiftlint:enable identifier_name

extension UIColor {
    public convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if (cString.count) != 6 {
            self.init(red: 1, green: 1, blue: 1, alpha: 1)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
