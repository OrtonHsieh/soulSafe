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
        dateFormatter.dateFormat = "MM/dd HH:mm"
    }
    
    func formatDate(timeStamp: Timestamp) -> String {
        let date = timeStamp.dateValue()
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    func calculateHoursPassed(from timeStamp: Timestamp) -> String {
        let date = timeStamp.dateValue()
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date, to: currentDate)
        // swiftlint:disable all
        if let hours = components.hour,
           let min = components.minute {
            if hours != 0 {
                return "\(hours) 小時 \(min) 分鐘前更新   "
            } else {
                return "\(min) 分鐘前更新   "
            }
        } else {
            return "無"
        }
        // swiftlint:enable all
    }
}
