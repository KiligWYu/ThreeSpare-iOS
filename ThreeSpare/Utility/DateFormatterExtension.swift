//
//  DateFormatterExtension.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/26.
//

import Foundation

public extension DateFormatter {
  class func formate(_ format: String) -> DateFormatter {
    let threadDic = Thread.current.threadDictionary
    var dateFormatter = threadDic.object(forKey: format) as? DateFormatter
    if dateFormatter == nil {
      dateFormatter = DateFormatter()
      dateFormatter!.dateFormat = format
      threadDic.setObject(dateFormatter!, forKey: NSString(string: format))
    }
    return dateFormatter!
  }
}
