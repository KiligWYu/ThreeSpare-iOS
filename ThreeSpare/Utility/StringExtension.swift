//
//  StringExtension.swift
//  ThreeSpare
//
//  Created by πΆππππ on 2022/3/8.
//

import Foundation

extension String {
  mutating func regexReplacingOccurrences(of regexPattern: String, with replacement: String) {
    guard let regularExpression = try? NSRegularExpression(pattern: regexPattern, options: .caseInsensitive) else {
      return
    }
    self = regularExpression.stringByReplacingMatches(in: self,
                                               range: NSRange(location: 0, length: self.count),
                                               withTemplate: replacement)
  }
}
