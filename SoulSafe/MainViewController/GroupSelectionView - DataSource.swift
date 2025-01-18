//
//  GroupSelectionView - DataSource.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/29.
//

import UIKit

protocol GroupSelectionStackViewDataSource: AnyObject {
    func numberOfButtons(in view: GroupSelectionStackView) -> Int
    func titleForButtons(at index: Int, in view: GroupSelectionStackView) -> String
    func buttonTextColor(in view: GroupSelectionStackView) -> UIColor
    func buttonBorderColor(in view: GroupSelectionStackView) -> CGColor
    func buttonBackgroundColor(in view: GroupSelectionStackView) -> UIColor
    func buttonTextFont(in view: GroupSelectionStackView) -> UIFont
}

extension GroupSelectionStackViewDataSource {
    func buttonTextColor(in view: GroupSelectionStackView) -> UIColor {
        UIColor(hex: CIC.shared.F1)
    }
    
    func buttonBackgroundColor(in view: GroupSelectionStackView) -> UIColor {
        UIColor(hex: CIC.shared.M2)
    }
    
    func buttonBorderColor(in view: GroupSelectionStackView) -> CGColor {
        UIColor(hex: CIC.shared.F2).cgColor
    }
    
    func buttonTextFont(in view: GroupSelectionStackView) -> UIFont {
        UIFont.systemFont(ofSize: 16)
    }
}
