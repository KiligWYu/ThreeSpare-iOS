//
//  DateExtension.swift
//  ThreeSpare
//
//  Created by πΆππππ on 2022/1/26.
//

import Foundation

extension Date {
  func dayOfWeek() -> Int {
    Calendar.current.dateComponents([.weekday], from: self).weekday!
  }
}
