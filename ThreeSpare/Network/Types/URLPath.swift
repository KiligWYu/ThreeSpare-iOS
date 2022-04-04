//
//  URLPath.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/3/4.
//

import Foundation

enum URLPath {
  case content
}

extension URLPath {
  var getRandomArticle: String {
    switch self {
    case .content:
      return "/xcxrandom"
    }
  }
}
