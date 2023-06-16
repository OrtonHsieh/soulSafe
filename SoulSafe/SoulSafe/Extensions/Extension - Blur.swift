//
//  Extension - Blur.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/16.
//

import UIKit

class Blur {
    static let shared = Blur()
    
    func setViewShadow(_ inputView: UIView) -> UIView {
        let inputView = inputView
        inputView.layer.masksToBounds = false
        
        inputView.layer.shadowColor = UIColor(red: 24 / 255, green: 183 / 255, blue: 231 / 255, alpha: 0.4).cgColor
        inputView.layer.shadowOpacity = 1.0
        inputView.layer.shadowRadius = 43
        inputView.layer.shadowOffset = CGSize(width: 0, height: 0)
        return inputView
    }
    
    func setImgViewShadow(_ inputView: UIImageView) -> UIImageView {
        let inputView = inputView
        inputView.layer.masksToBounds = false
        
        inputView.layer.shadowColor = UIColor(red: 24 / 255, green: 183 / 255, blue: 231 / 255, alpha: 0.4).cgColor
        inputView.layer.shadowOpacity = 1.0
        inputView.layer.shadowRadius = 43
        inputView.layer.shadowOffset = CGSize(width: 0, height: 0)
        return inputView
    }
    
    func setButtonShadow(_ inputButton: UIButton) -> UIButton {
        let inputButton = inputButton
        inputButton.layer.masksToBounds = false
        
        inputButton.layer.shadowColor = UIColor(red: 24 / 255, green: 183 / 255, blue: 231 / 255, alpha: 0.4).cgColor
        inputButton.layer.shadowOpacity = 1.0
        inputButton.layer.shadowRadius = 43
        inputButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        return inputButton
    }
}
