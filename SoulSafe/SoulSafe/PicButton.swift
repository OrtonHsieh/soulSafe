//
//  PicButton.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/16.
//

import UIKit

class PicButton: UIButton {
    private var isButtonHighlighted = false
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted != isButtonHighlighted {
                isButtonHighlighted = isHighlighted
                updateButtonAppearance()
            }
        }
    }
    
    var WAForButton: NSLayoutConstraint?
    var HAForButton: NSLayoutConstraint?
    var value: CGFloat = 84
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Customize the button appearance
        setupButton()
        
        WAForButton = widthAnchor.constraint(equalToConstant: value)
        WAForButton?.isActive = true
        HAForButton = heightAnchor.constraint(equalToConstant: value)
        HAForButton?.isActive = true
        layer.borderWidth = 4
        layer.cornerRadius = 42
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupButton() {
        // Add custom styling to the button
        layer.cornerRadius = 42
        backgroundColor = UIColor.white
        layer.borderWidth = 4
        layer.borderColor = UIColor.black.cgColor
    }
    
    private func updateButtonAppearance() {
        if isButtonHighlighted {
            // Update the button's appearance for the highlighted state
            Vibration.shared.hardV()
            value = 80
            layer.borderWidth = 8
            layer.cornerRadius = 42
        } else {
            // Update the button's appearance for the normal state
            Vibration.shared.lightV()
            value = 84
            layer.borderWidth = 4
            layer.cornerRadius = 42
        }
    }
}
