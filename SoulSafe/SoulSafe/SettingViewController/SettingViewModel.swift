//
//  SettingViewModel.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/11.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SettingViewModel {
    enum AccountError: Error {
        case invalidToken
        case upload
    }
    // swiftlint:disable all
    let db = Firestore.firestore()
    // swiftlint:enable all
    
    func setupPersonalInfo(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let userID = UserDefaults.standard.object(forKey: "userID") else { return }
        let getPersonalInfoPath = db.collection("users").document("\(userID)")
        getPersonalInfoPath.getDocument { snapshot, err in
            if let err = err {
                completion(.failure(err))
            } else {
                guard let snapshot = snapshot else { return }
                guard let data = snapshot.data() else { return }
                guard let userAvatar = data["userAvatar"] as? String else { return }
                guard let userName = data["userName"] as? String else { return }
                var userInfo: [String: Any] = [:]
                userInfo["userAvatar"] = userAvatar
                userInfo["userName"] = userName
                completion(.success(userInfo))
            }
        }
    }
    
    func deleteUserAccount(completion: @escaping (Result<Void, AccountError>) -> Void) {
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                print("Failed to delete user account: \(error)")
                completion(.failure(.invalidToken))
            } else {
                guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
                // 先刪掉 group 再刪掉 post 最後刪掉 document 路徑
                let accountDeletePath = self.db.collection("users").document("\(userID)")
                accountDeletePath.delete { err in
                    if let err = err {
                        completion(.failure(.upload))
                        print("Error removing document: \(err)")
                    } else {
                        completion(.success(()))
                        print("Account deleted.")
                    }
                }
            }
        }
    }
    
    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileReference = Storage.storage().reference().child(UUID().uuidString + ".jpg")
        if let data = image.jpegData(compressionQuality: 0.1) {
            fileReference.putData(data, metadata: nil) { result in
                switch result {
                case .success:
                    fileReference.downloadURL(completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func storeAvatarToFireStoreUsersCollection(url: (URL), userID: Any, completion: @escaping (Result<Void, Error>) -> Void) {
        let storeAvatarPath = self.db.collection("users").document("\(userID)")
        storeAvatarPath.setData(
            [
                "userAvatar": "\(url)",
                "userID": "\(userID)"
            ],
            merge: true
        ) { err in
            if let err = err {
                completion(.failure(err))
            } else {
                print("Upload userAvatar to user path successfully.")
                completion(.success(()))
            }
        }
    }
    
    func updateUserName(userName: String, userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let storeNamePath = self.db.collection("users").document("\(userID)")
        storeNamePath.setData(
            ["userName": "\(userName)"],
            merge: true) { err in
            if let err = err {
                completion(.failure(err))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateUserNameInGroups(userID: String, userName: String, groupIDs: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        let groupPath = db.collection("groups")
        for groupID in groupIDs {
            let groupPathToMembers = groupPath.document("\(groupID)").collection("members")
            let storeNameInGroupMemberListPath = groupPathToMembers.document("\(userID)")
            storeNameInGroupMemberListPath.setData(
                ["userName": "\(userName)"],
                merge: true) { err in
                if let err = err {
                    completion(.failure(err))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func storeAvatarToFireStoreGroupsCollection(groupIDs: [String], url: (URL), userID: Any) {
        let groupPath = self.db.collection("groups")
        for groupID in groupIDs {
            let groupPathToMembers = groupPath.document("\(groupID)").collection("members")
            let storeAvatarInGroupMemberListPath = groupPathToMembers.document("\(userID)")
            storeAvatarInGroupMemberListPath.setData(
                ["userAvatar": "\(url)"],
                merge: true
            ) { err in
                if let err = err {
                    print(err)
                } else {
                    print("Upload userAvatar to user path successfully.")
                }
            }
        }
    }
}
