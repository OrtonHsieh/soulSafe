//
//  SignInViewModelDefault.swift
//  SoulSafe
//
//  Created by OrtonHsieh on 2025/2/27.
//

import Foundation

final class SignInViewModelDefault: SignInViewModel {
    private weak var delegate: SignInViewModelDelegate?
    
    init(delegate: SignInViewModelDelegate) {
        self.delegate = delegate
    }
    
    func cancel() {
        delegate?.cancel()
    }
}
