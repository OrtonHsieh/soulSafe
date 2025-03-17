//
//  AppCoordinator.swift
//  SoulSafe
//
//  Created by OrtonHsieh on 2025/2/27.
//

import Foundation
import UIKit
import AuthenticationServices

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let viewModelFactory: ViewModelFactory
    private var pendingDeepLink: DeepLink?
    
    init(
        navigationController: UINavigationController,
        viewModelFactory: ViewModelFactory
    ) {
        self.navigationController = navigationController
        self.viewModelFactory = viewModelFactory
    }
    
    func start() {
        print("AppCoordinator starting...")
        print("Navigation controller:", navigationController)
        
        observeAppleIDSessionChanges()
        showAuthFlow()
    }
    
    private func observeAppleIDSessionChanges() {
        NotificationCenter.default.addObserver(
            forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let self = self else { return }
            // Sign user in or out
            print("Sign user in or out...")
            navigationController.setViewControllers([], animated: true)
            showAuthFlow()
        }
    }
    
    func handleDeepLink(_ deepLink: DeepLink) {
        switch deepLink {
        case .joinGroup(let groupID):
            if let mainCoordinator = childCoordinators.first(where: { $0 is GroundCoordinator }) as? GroundCoordinator {
                mainCoordinator.showJoinGroup(groupID: groupID)
            } else {
                // Store the deep link to handle after login if user is not authenticated
                pendingDeepLink = deepLink
                showAuthFlow()
            }
            
        case .profile:
            // Handle profile deep link
            break
            
        case .settings:
            // Handle settings deep link
            break
        }
    }
    
    private func showAuthFlow() {
        print("Showing auth flow...")
        let signInCoordinator = SignInCoordinator(
            navigationController: navigationController,
            viewModelFactory: viewModelFactory,
            delegate: self
        )
        addChildCoordinator(signInCoordinator)
        signInCoordinator.start()
    }
    
    private func showMainFlow() {
        let mainCoordinator = GroundCoordinator(
            navigationController: navigationController,
            viewModelFactory: viewModelFactory,
            delegate: self
        )
        addChildCoordinator(mainCoordinator)
        mainCoordinator.start()
    }
}

extension AppCoordinator: SignInCoordinatorDelegate {
    func routeToGroundViewController() {
        showMainFlow()
    }
}

extension AppCoordinator: GroundCoordinatorDelegate {
    func routeToSignInViewController() {
        UserDefaults.standard.removeObject(forKey: "userIDForAuth")
        showAuthFlow()
    }
}
