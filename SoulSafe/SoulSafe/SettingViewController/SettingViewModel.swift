//
//  SettingViewModel.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/11.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

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
}
