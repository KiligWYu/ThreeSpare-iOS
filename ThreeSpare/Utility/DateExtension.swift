//
//  DateExtension.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/26.
//

import Foundation

extension Date {
  func dayOfWeek() -> Int {
    Calendar.current.dateComponents([.weekday], from: self).weekday!
  }
}
