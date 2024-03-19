//
//  Extension + Date.swift
//  Tracker
//
//  Created by Алексей on 18.03.2024.
//

import Foundation

extension Date {
    var onlyDate: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
}
