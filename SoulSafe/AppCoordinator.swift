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
    
    init(navigationController: UINavigationController,
         viewModelFactory: ViewModelFactory) {
        self.navigationController = navigationController
        self.viewModelFactory = viewModelFactory
    }
    
    func start() {
        observeAppleIDSessionChanges()
        observeIfUserLogout()
        showAuthFlow()
    }
    
    private func observeAppleIDSessionChanges() {
        NotificationCenter.default.addObserver(
            forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil,
            queue: nil
        ) { _ in
            // Sign user in or out
            print("Sign user in or out...")
        }
    }
    
    private func observeIfUserLogout() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func userDefaultsDidChange(notification: Notification) {
        if let defaults = notification.object as? UserDefaults {
            if defaults.object(forKey: "userIDForAuth") == nil {
                routeToSignInViewController()
            }
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
        let authCoordinator = SignInCoordinator(
            navigationController: navigationController,
            viewModelFactory: viewModelFactory,
            delegate: self
        )
        addChildCoordinator(authCoordinator)
        authCoordinator.start()
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
        showAuthFlow()
    }
}
