//
//  NetworkURL.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/3/4.
//

import Foundation

enum NetworkURL {
  case getRandomArticle
}

extension NetworkURL {
  static var baseURL: URL? {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "meiriyiwen.com"
    components.path = "/json"
    guard let url = components.url else { return nil }
    return url
  }

  var url: URL? {
    switch self {
    case .getRandomArticle:
      let baseURL = NetworkURL.baseURL?.absoluteString ?? ""
      return URL(string: "\(baseURL)\(URLPath.content.getRandomArticle)")
    }
  }
}
