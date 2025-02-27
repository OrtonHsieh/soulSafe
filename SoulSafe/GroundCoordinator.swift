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
    
    init(navigationController: UINavigationController,
         viewModelFactory: ViewModelFactory,
         delegate: GroundCoordinatorDelegate) {
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
            groundViewController.modalPresentationStyle = .fullScreen
            Vibration.shared.lightV()
            // Present the GroundViewController from the current view controller
            navigationController.present(groundViewController, animated: true, completion: nil)
        }
    }
    
    func showJoinGroup(groupID: String) {
        
    }
}

extension GroundCoordinator: GroundViewModelDelegate {
    func routeToSignInViewController() {
        delegate?.routeToSignInViewController()
    }
}

