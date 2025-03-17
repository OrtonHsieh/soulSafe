//
//  MainCoordinator.swift
//  SoulSafe
//
//  Created by OrtonHsieh on 2025/2/27.
//

import Foundation
import UIKit

protocol GroundCoordinatorDelegate: AnyObject {
    func routeToSignInViewController()
}

final class GroundCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let viewModelFactory: ViewModelFactory
    private weak var delegate: GroundCoordinatorDelegate?
    
    init(
        navigationController: UINavigationController,
        viewModelFactory: ViewModelFactory,
        delegate: GroundCoordinatorDelegate
    ) {
        self.navigationController = navigationController
        self.viewModelFactory = viewModelFactory
        self.delegate = delegate
    }
    
    func start() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let groundViewController = GroundViewController(
                viewModel: viewModelFactory.makeGroundViewModel(delegate: self)
            )
            Vibration.shared.lightV()
            // Instead of presenting modally, set as root of navigation stack
            navigationController.setViewControllers([groundViewController], animated: true)
        }
    }
    
    func showJoinGroup(groupID: String) {}
}

extension GroundCoordinator: GroundViewModelDelegate {
    func routeToSignInViewController() {
        // First dismiss the current view controller
        navigationController.dismiss(animated: true) { [weak self] in
            // Then notify delegate to handle sign in flow
            self?.delegate?.routeToSignInViewController()
        }
    }
}
