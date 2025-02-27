//
//  DatabaseProvider.swift
//  SoulSafe
//
//  Created by OrtonHsieh on 2025/2/27.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum ApiResult<T> {
    case success(T)
    case failure(Error)
}

final class DatabaseProvider {
    static let database = Firestore.firestore()
    
    static func getData(collection: String, document: String) -> DocumentReference {
        return database.collection(collection).document(document)
    }
}
