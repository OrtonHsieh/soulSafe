//
//  SignInPage.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/7.
//
import UIKit
import AuthenticationServices
import FirebaseFirestore
import FirebaseAuth
import CryptoKit

class SignInViewController: UIViewController {
    let brandImgView = UIImageView()
    let db = Firestore.firestore()
    var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkSignInStatus()
    }
    
    private func checkSignInStatus() {
        if let userIDForAuth = UserDefaults.standard.string(forKey: "userIDForAuth") {
            // Check the login status of Apple sign in for the app
            // Asynchronous
            let userID = UserDefaults.standard.string(forKey: "userID")
            let checkIfUserExistedPath = db.collection("users").document("\(userID)")
            checkIfUserExistedPath.getDocument { snapshot, err in
                if let err = err {
                    print(err)
                } else {
                    guard let snapshot = snapshot else { return }
                    guard let data = snapshot.data() else {
                        self.setupView()
                        self.setupConstraints()
                        self.setupSignInWithApple()
                        return
                    }
                    ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userIDForAuth) { credentialState, error in
                        switch credentialState {
                        case .authorized:
                            print("User remains logged in. Proceed to another view.")
                            // Present BaseVC
                            DispatchQueue.main.async {
                                let bsViewController = BSViewController()
                                bsViewController.modalPresentationStyle = .fullScreen
                                Vibration.shared.lightV()
                                
                                // Present the BSViewController from the current view controller
                                self.present(bsViewController, animated: true, completion: nil)
                            }
                        case .revoked:
                            print("User logged in before but revoked.")
                            self.setupView()
                            self.setupConstraints()
                            self.setupSignInWithApple()
                        case .notFound:
                            print("User logged in before but revoked.")
                            self.setupView()
                            self.setupConstraints()
                            self.setupSignInWithApple()
                        default:
                            print("Unknown state.")
                        }
                    }
                }
            }
        } else {
            setupView()
            setupConstraints()
            setupSignInWithApple()
        }
    }
    
    func setupView() {
        DispatchQueue.main.async {
            self.view.addSubview(self.brandImgView)
            self.brandImgView.image = UIImage(named: "brandImg")
            self.brandImgView.clipsToBounds = false
        }
    }
    
    func setupConstraints() {
        DispatchQueue.main.async {
            self.brandImgView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.brandImgView.widthAnchor.constraint(equalToConstant: 360),
                self.brandImgView.heightAnchor.constraint(equalToConstant: 374.814),
                self.brandImgView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50),
                self.brandImgView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            ])
        }
    }
    
    func setupSignInWithApple() {
        DispatchQueue.main.async {
            // Do any additional setup after loading the view.
            
            let siwaButton = ASAuthorizationAppleIDButton()
            
            // set this so the button will use auto layout constraint
            siwaButton.translatesAutoresizingMaskIntoConstraints = false
            
            // add the button to the view controller root view
            self.view.addSubview(siwaButton)
            self.view.backgroundColor = UIColor(hex: CIC.shared.M1)
            
            // set constraint
            NSLayoutConstraint.activate([
                siwaButton.leadingAnchor.constraint(
                    equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 50.0
                ),
                siwaButton.trailingAnchor.constraint(
                    equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -50.0
                ),
                siwaButton.bottomAnchor.constraint(
                    equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -70.0
                ),
                siwaButton.heightAnchor.constraint(
                    equalToConstant: 50.0
                )
            ])
            // the function that will be executed when user tap the button
            siwaButton.addTarget(self, action: #selector(self.appleSignInTapped), for: .touchUpInside)
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
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // return the current view window
        return self.view.window!
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {
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
        @unknown default:
            print("Default")
        }
    }
    
    /// 授權成功
    /// - Parameters:
    ///   - controller: _
    ///   - authorization: _
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // unique ID for each user, this uniqueID will always be returned
            let userIDForAuth = appleIDCredential.user
            UserDefaults.standard.set(userIDForAuth, forKey: "userIDForAuth")

            // optional, might be nil
            let email = appleIDCredential.email

            // optional, might be nil
            let givenName = appleIDCredential.fullName?.givenName

            // optional, might be nil
            let familyName = appleIDCredential.fullName?.familyName

            // optional, might be nil
            let nickName = appleIDCredential.fullName?.nickname

            /*
                useful for server side, the app can send identityToken and authorizationCode
                to the server for verification purpose
            */
            guard let nonce = currentNonce else {
                fatalError("Invalid state: a login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token.")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
//            var identityToken: String?
//            if let token = appleIDCredential.identityToken {
//                identityToken = String(bytes: token, encoding: .utf8)
//            }
//
//            var authorizationCode: String?
//            if let code = appleIDCredential.authorizationCode {
//                authorizationCode = String(bytes: code, encoding: .utf8)
//            }
            
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce)
            
            Task {
                do {
                    let result = try await Auth.auth().signIn(with: credential)
                    guard let userID = Auth.auth().currentUser?.uid else { return }
                    print(userID)
                    // save it to user defaults
                    UserDefaults.standard.set(userID, forKey: "userID")
                    UserDefaults.standard.set("defaultAvatar", forKey: "userAvatar")
                    
                    // UploadUserID to fireStore
                    db.collection("users").document("\(userID)").setData([
                        "userID": "\(userID)",
                        "userAvatar": "defaultAvatar"
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("UploadUserID to fireStore successfully.")
                        }
                    }
                    // store the data and get into main page
                    DispatchQueue.main.async {
                        let bsViewController = BSViewController()
                        bsViewController.modalPresentationStyle = .fullScreen
                        Vibration.shared.lightV()
                        
                        // Present the BSViewController from the current view controller
                        self.present(bsViewController, animated: true, completion: nil)
                    }
                }
                catch {
                    print("Error authenticating: \(error.localizedDescription)")
                }
            }
        }
    }
}
