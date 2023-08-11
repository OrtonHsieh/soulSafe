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
