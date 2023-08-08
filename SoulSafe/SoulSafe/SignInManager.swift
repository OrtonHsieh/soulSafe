//
//  SignInManager.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/7/24.
//
import UIKit
import AuthenticationServices
import FirebaseFirestore
import FirebaseAuth
import CryptoKit

class SignInManager {
    // swiftlint:disable all
    private let db: Firestore // Assuming Firestore is your database reference
    
    init(db: Firestore) {
        self.db = db
    }
    // swiftlint:enable all
    
    var userAvatar = ""
    var userName = ""
    
    func handleAppleIDAuthorization(appleIDCredential: ASAuthorizationAppleIDCredential, nonce: String, completion: @escaping (Bool) -> Void) {
        let userIDForAuth = appleIDCredential.user
        UserDefaults.standard.set(userIDForAuth, forKey: "userIDForAuth")
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token.")
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce)
        
        Task {
            do {
                _ = try await Auth.auth().signIn(with: credential)
                guard let userID = Auth.auth().currentUser?.uid else { return }
                print(userID)
                // save it to user defaults
                UserDefaults.standard.set(userID, forKey: "userID")
                
                var didUploadAllInfo = 0 {
                    didSet {
                        if didUploadAllInfo == 2 {
                            completion(true)
                        }
                    }
                }
                
                if UserDefaults.standard.object(forKey: "userAvatar") != nil {
                    guard let userAvatarFromDefault = UserDefaults.standard.object(
                        forKey: "userAvatar"
                    ) as? String else { return }
                    userAvatar = userAvatarFromDefault
                    didUploadAllInfo += 1
                } else {
                    db.collection("users").document("\(userID)").getDocument { snapshot, err in
                        if let err = err {
                            print(err)
                        } else {
                            guard let snapshot = snapshot else { return }
                            guard let data = snapshot.data() else {
                                self.userAvatar = "defaultAvatar"
                                UserDefaults.standard.set("\(self.userAvatar)", forKey: "userAvatar")
                                uploadUserAvatar()
                                return
                            }
                            guard let userAvatarFromUsersCollection = data["userAvatar"] as? String else { return }
                            self.userAvatar = userAvatarFromUsersCollection
                            UserDefaults.standard.set("\(self.userAvatar)", forKey: "userAvatar")
                            uploadUserAvatar()
                        }
                    }
                }
                
                if UserDefaults.standard.object(forKey: "userName") != nil {
                    guard let userNameFromDefault = UserDefaults.standard.object(
                        forKey: "userName"
                    ) as? String else { return }
                    userName = userNameFromDefault
                    didUploadAllInfo += 1
                } else {
                    db.collection("users").document("\(userID)").getDocument { snapshot, err in
                        if let err = err {
                            print(err)
                        } else {
                            guard let snapshot = snapshot else { return }
                            guard let data = snapshot.data() else {
                                self.userName = "尚未設定名稱"
                                UserDefaults.standard.set("\(self.userName)", forKey: "userName")
                                uploadUserName()
                                return
                            }
                            guard let userAvatarFromUsersCollection = data["userName"] as? String else { return }
                            self.userName = userAvatarFromUsersCollection
                            UserDefaults.standard.set("\(self.userName)", forKey: "userName")
                            uploadUserName()
                        }
                    }
                }
                
                func uploadUserAvatar() {
                    // UploadUserID to fireStore
                    db.collection("users").document("\(userID)").setData(
                        [
                            "userID": "\(userID)",
                            "userAvatar": "\(userAvatar)"
                        ],
                        merge: true) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("UploadUserID to fireStore successfully.")
                                didUploadAllInfo += 1
                            }
                        }
                }
                
                func uploadUserName() {
                    // UploadUserID to fireStore
                    db.collection("users").document("\(userID)").setData(
                        [
                            "userID": "\(userID)",
                            "userName": "\(userName)"
                        ],
                        merge: true) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("UploadUserID to fireStore successfully.")
                                didUploadAllInfo += 1
                            }
                        }
                }
            } catch {
                print("Error authenticating: \(error.localizedDescription)")
            }
        }
    }
}
