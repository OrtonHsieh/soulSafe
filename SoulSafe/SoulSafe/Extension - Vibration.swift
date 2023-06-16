//
//  Extension - Vibration.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/16.
//

import UIKit

class Vibration {
    static let shared = Vibration()
    
    private init() {}
    
    func hardV() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    func mediumV() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    func lightV() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
}
