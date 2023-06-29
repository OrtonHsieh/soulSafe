//
//  GroupSelectionView - Delegate.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/29.
//

import UIKit

protocol GroupSelectionStackViewDelegate: AnyObject {
    func groupSelectionStackView(_ view: GroupSelectionStackView, didSelectButton button: UIButton)
}
