//
//  ViewModelFactory.swift
//  SoulSafe
//
//  Created by OrtonHsieh on 2025/2/27.
//

import Foundation

final class ViewModelFactory {
    private let container: DependencyContainerProtocol
    
    init(container: DependencyContainerProtocol) {
        self.container = container
    }
    
    // Auth
    func makeSignInViewModel(delegate: SignInViewModelDelegate) -> some SignInViewModel {
        return SignInViewModelDefault(delegate: delegate)
    }
    
    func makeGroundViewModel(delegate: GroundViewModelDelegate) -> some GroundViewModel {
        return GroundViewModelDefault(delegate: delegate)
    }
//
//    func makeSignUpViewModel() -> SignUpViewModel {
//        return SignUpViewModel(
//            signUpUseCase: container.makeSignUpUseCase()
//        )
//    }
//    
//    // Main Flow
//    func makeHomeViewModel() -> HomeViewModel {
//        return HomeViewModel(
//            getGroupsUseCase: container.makeGetGroupsUseCase()
//        )
//    }
//    
//    func makeProfileViewModel() -> ProfileViewModel {
//        return ProfileViewModel(
//            getUserUseCase: container.makeGetUserUseCase()
//        )
//    }
}
