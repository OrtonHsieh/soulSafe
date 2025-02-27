//
//  GroundViewModelDefault.swift
//  SoulSafe
//
//  Created by OrtonHsieh on 2025/2/27.
//

import Foundation

final class GroundViewModelDefault: GroundViewModel {
    private weak var delegate: GroundViewModelDelegate?
    
    init(delegate: GroundViewModelDelegate? = nil) {
        self.delegate = delegate
    }
    
    func routeToSignInViewController() {
        delegate?.routeToSignInViewController()
    }
}
