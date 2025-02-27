//
//  SignInCoordinator.swift
//  SoulSafe
//
//  Created by OrtonHsieh on 2025/2/27.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices

protocol SignInCoordinatorDelegate: AnyObject {
    func routeToGroundViewController()
}

final class SignInCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let viewModelFactory: ViewModelFactory
    private weak var delegate: SignInCoordinatorDelegate?
    
    init(navigationController: UINavigationController,
         viewModelFactory: ViewModelFactory,
         delegate: SignInCoordinatorDelegate) {
        self.navigationController = navigationController
        self.viewModelFactory = viewModelFactory
        self.delegate = delegate
    }
    
    func start() {
        guard let authID = getAuthID(),
              let userID = getUserID() else {
            routeToSignInViewController()
            return
        }
        
        fetchData(userIDForAuth: authID, userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                guard let _ = data.data() else {
                    routeToSignInViewController()
                    return
                }
                shouldRouteToGroundViewController(userIDForAuth: authID) { [weak self] boolValue in
                    guard let self = self else { return }
                    if boolValue {
                        routeToGroundViewController()
                    } else {
                        routeToSignInViewController()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func routeToGroundViewController() {
        delegate?.routeToGroundViewController()
    }
    
    private func shouldRouteToGroundViewController(userIDForAuth: String, completion: @escaping (Bool) -> Void) {
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userIDForAuth) { credentialState, _ in
            switch credentialState {
            case .authorized:
                print("User remains logged in. Proceed to another view.")
                completion(true)
            case .revoked:
                print("User logged in before but revoked.")
                completion(false)
            case .notFound:
                print("User logged in before but revoked.")
                completion(false)
            default:
                completion(false)
            }
        }
    }

    private func getAuthID() -> String? {
        UserDefaults.standard.string(forKey: "userIDForAuth")
    }
    
    private func getUserID() -> String? {
        UserDefaults.standard.string(forKey: "userID")
    }
    
    private func fetchData(userIDForAuth: String, userID: String, completion: @escaping (ApiResult<DocumentSnapshot>) -> Void) {
        let documentReference = DatabaseProvider.getData(collection: "users", document: userID)
        documentReference.getDocument { snapshot, err in
            if let err = err {
                completion(.failure(err))
            } else {
                guard let snapshot = snapshot else { return }
                completion(.success(snapshot))
            }
        }
    }
    
    private func routeToSignInViewController() {
        let viewController = SignInViewController(
            signInHelper: SignInHelper(db: Firestore.firestore()),
            viewModel: viewModelFactory.makeSignInViewModel(delegate: self)
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension SignInCoordinator: SignInViewModelDelegate {
    func cancel() {
        routeToGroundViewController()
    }
}
