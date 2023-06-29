//
//  Extension - DateFormator.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/6/28.
//

import UIKit
import Foundation
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

class CusDateFormatter {
    static let shared = CusDateFormatter()
    private let dateFormatter: DateFormatter
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func formatDate(timeStamp: Timestamp) -> String {
        let date = timeStamp.dateValue()
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}
