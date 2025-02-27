//
//  SignInViewController.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/7.
//
import UIKit
import AuthenticationServices
import FirebaseFirestore
import FirebaseAuth
import CryptoKit

class SignInViewController<ViewModel: SignInViewModel>: UIViewController, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    let brandImgView = UIImageView()
    // swiftlint:disable all
    let db = Firestore.firestore()
    // swiftlint:enable all
    let activityIndicator = UIActivityIndicatorView(style: .large)
    var currentNonce: String?
    let siwaButton = ASAuthorizationAppleIDButton()
    private var signInHelper: SignInHelper
    let viewModel: ViewModel
    
    init(signInHelper: SignInHelper, viewModel: ViewModel) {
        self.signInHelper = signInHelper
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupConstraints()
        self.view.backgroundColor = UIColor(hex: CIC.shared.M1)
//        checkSignInStatus()
    }
    
//    private func checkSignInStatus() {
//        if let userIDForAuth = UserDefaults.standard.string(forKey: "userIDForAuth") {
//            // Check the login status of Apple sign in for the app
//            // Asynchronous
//            guard let userID = UserDefaults.standard.string(forKey: "userID") else {
//                setupView()
//                setupConstraints()
//                setupSignInWithApple()
//                return
//            }
//            let checkIfUserExistedPath = db.collection("users").document("\(userID)")
//            checkIfUserExistedPath.getDocument { snapshot, err in
//                if let err = err {
//                    print(err)
//                } else {
//                    guard let snapshot = snapshot else { return }
//                    // 這邊是判斷 users 的 collection 是否也有該 user
//                    if snapshot.data() == nil {
//                        self.setupView()
//                        self.setupConstraints()
//                        self.setupSignInWithApple()
//                        return
//                    } else {
//                        let provider = ASAuthorizationAppleIDProvider()
//                        provider.getCredentialState(forUserID: userIDForAuth) { credentialState, _ in
//                            switch credentialState {
//                            case .authorized:
//                                print("User remains logged in. Proceed to another view.")
//                                // Present BaseVC
//                                DispatchQueue.main.async {
//                                    let groundViewController = GroundViewController()
//                                    groundViewController.modalPresentationStyle = .fullScreen
//                                    Vibration.shared.lightV()
//                                    // Present the GroundViewController from the current view controller
//                                    self.present(groundViewController, animated: true, completion: nil)
//                                }
//                            case .revoked:
//                                print("User logged in before but revoked.")
//                                self.setupSignInWithApple()
//                            case .notFound:
//                                print("User logged in before but revoked.")
//                                self.setupSignInWithApple()
//                            default:
//                                print("Unknown state.")
//                            }
//                        }
//                    }
//                }
//            }
//        } else {
//            setupView()
//            setupConstraints()
//            setupSignInWithApple()
//        }
//    }
//    
    func setupView() {
        DispatchQueue.main.async {
            self.view.addSubview(self.brandImgView)
            self.brandImgView.image = UIImage(named: "brandImg")
            self.brandImgView.clipsToBounds = false
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.color = .gray
        }
    }
    
    func setupConstraints() {
        DispatchQueue.main.async {
            self.brandImgView.translatesAutoresizingMaskIntoConstraints = false
            self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.brandImgView.widthAnchor.constraint(equalToConstant: 360),
                self.brandImgView.heightAnchor.constraint(equalToConstant: 374.814),
                self.brandImgView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50),
                self.brandImgView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                
                self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            ])
        }
    }
    
    func setupSignInWithApple() {
        DispatchQueue.main.async {
            // Do any additional setup after loading the view.
            // set this so the button will use auto layout constraint
            self.siwaButton.translatesAutoresizingMaskIntoConstraints = false
            
            // add the button to the view controller root view
            self.view.addSubview(self.siwaButton)
            self.view.backgroundColor = UIColor(hex: CIC.shared.M1)
            
            // set constraint
            NSLayoutConstraint.activate([
                self.siwaButton.leadingAnchor.constraint(
                    equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 50.0
                ),
                self.siwaButton.trailingAnchor.constraint(
                    equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -50.0
                ),
                self.siwaButton.bottomAnchor.constraint(
                    equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -70.0
                ),
                self.siwaButton.heightAnchor.constraint(
                    equalToConstant: 50.0
                )
            ])
            // the function that will be executed when user tap the button
            self.siwaButton.addTarget(self, action: #selector(self.appleSignInTapped), for: .touchUpInside)
        }
    }
    
    // this is the function that will be executed when user tap the button
    @objc func appleSignInTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        // request full name and email from the user's Apple ID
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        
        // pass the request to the initializer of the controller
        let authController = ASAuthorizationController(authorizationRequests: [request])
        
        // similar to delegate, this will ask the view controller
        // which window to present the ASAuthorizationController
        authController.presentationContextProvider = self
        // delegate functions will be called when user data is
        // successfully retrieved or error occured
        authController.delegate = self
        
        // show the Sign-in with Apple dialog
        authController.performRequests()
    }
    
    // For every sign-in request, generate a random string—a "nonce"—which you will use to make sure the ID token you get was granted specifically in response to your app's authentication request. This step is important to prevent replay attacks.
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    // You will send the SHA256 hash of the nonce with your sign-in request, which Apple will pass unchanged in the response. Firebase validates the response by hashing the original nonce and comparing it to the value passed by Apple.
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        
        return hashString
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // return the current view window
        // swiftlint:disable all
        return self.view.window!
        // swiftlint:enable all
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    /// 授權失敗
    /// - Parameters:
    ///   - controller: _
    ///   - error: _
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("authorization error")
        guard let error = error as? ASAuthorizationError else {
            return
        }
        
        switch error.code {
        case .canceled:
            // user press "cancel" during the login prompt
            print("Canceled")
        case .unknown:
            // user didn't login their Apple ID on the device
            print("Unknown")
        case .invalidResponse:
            // invalid response received from the login
            print("Invalid respone")
        case .notHandled:
            // authorization request not handled, maybe internet failure during login
            print("Not handled")
        case .failed:
            // authorization failed
            print("Failed")
        case .notInteractive:
            print("Note interactive")
        default:
            print("Default")
        }
    }
    
    /// 授權成功
    /// - Parameters:
    ///   - controller: _
    ///   - authorization: _
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            self.activityIndicator.startAnimating()
            self.siwaButton.isUserInteractionEnabled = false
            guard let nonce = currentNonce else {
                fatalError("Invalid state: a login callback was received, but no login request was sent.")
            }
            signInHelper.handleAppleIDAuthorization(
                appleIDCredential: appleIDCredential,
                nonce: nonce) { [weak self] success in
                guard let self = self else { return }
                if success {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.siwaButton.isUserInteractionEnabled = true
                        self.viewModel.cancel()
                    }
                } else {
                    print("Error authenticating.")
                }
            }
        }
    }
}
