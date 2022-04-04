//
//  APIManager.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/3/4.
//

import Foundation
import Combine

class APIManager<T: Decodable> {
  struct Model {
    let url: URL?
    let method: HTTPMethod
  }

  static var shared: APIManager<T> {
    return APIManager<T>()
  }

  private init() {}

  func request(with model: Model) -> AnyPublisher<T, Error> {
    guard let url = model.url else {
      return Fail(error: NSError(domain: "Missing API URL", code: -10001, userInfo: nil))
        .eraseToAnyPublisher()
    }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = model.method.rawValue
    return URLSession.shared
      .dataTaskPublisher(for: urlRequest)
      .tryMap { (data, response) in
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
          throw URLError(.badServerResponse)
        }
        return data
      }
      .decode(type: T.self, decoder: JSONDecoder())
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}
