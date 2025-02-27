//
//  DependencyContainer.swift
//  SoulSafe
//
//  Created by OrtonHsieh on 2025/2/27.
//

import Foundation

protocol DependencyContainerProtocol {
//    // UseCases
//    func makeSignInUseCase() -> SignInUseCaseProtocol
//    func makeSignUpUseCase() -> SignUpUseCaseProtocol
//    func makeGetGroupsUseCase() -> GetGroupsUseCaseProtocol
//    func makeGetUserUseCase() -> GetUserUseCaseProtocol
//    
//    // Repositories
//    func makeUserRepository() -> UserRepositoryProtocol
//    func makeGroupRepository() -> GroupRepositoryProtocol
}

class DependencyContainer: DependencyContainerProtocol {
    static let shared = DependencyContainer()
    
    private init() {}
    
    // MARK: - UseCases
//    func makeSignInUseCase() -> SignInUseCaseProtocol {
//        return SignInUseCase(repository: makeUserRepository())
//    }
//    
//    func makeSignUpUseCase() -> SignUpUseCaseProtocol {
//        return SignUpUseCase(repository: makeUserRepository())
//    }
//    
//    func makeGetGroupsUseCase() -> GetGroupsUseCaseProtocol {
//        return GetGroupsUseCase(repository: makeGroupRepository())
//    }
    
    // MARK: - Repositories
//    func makeUserRepository() -> UserRepositoryProtocol {
//        return UserRepository(
//            authService: makeAuthService(),
//            storage: makeStorage()
//        )
//    }
//    
//    func makeGroupRepository() -> GroupRepositoryProtocol {
//        return GroupRepository(
//            networkService: makeNetworkService(),
//            storage: makeStorage()
//        )
//    }
    
    // MARK: - Services
//    private func makeAuthService() -> AuthServiceProtocol {
//        return FirebaseAuthService()
//    }
//    
//    private func makeNetworkService() -> NetworkServiceProtocol {
//        return NetworkService()
//    }
//    
//    private func makeStorage() -> StorageProtocol {
//        return UserDefaultsStorage()
//    }
}
