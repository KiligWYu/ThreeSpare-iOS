//
//  UserDefault.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/13.
//

import Foundation

@propertyWrapper
struct UserDefault<Value> {
  let key: String
  let defaultValue: Value
  var container = UserDefaults.standard

  var wrappedValue: Value {
    get {
      container.object(forKey: key) as? Value ?? defaultValue
    }
    set {
      if let optional = newValue as? AnyOptional, optional.isNil {
        container.removeObject(forKey: key)
      } else {
        container.set(newValue, forKey: key)
      }
    }
  }
}

extension UserDefault where Value: ExpressibleByNilLiteral {
  init(key: String, _ container: UserDefaults = .standard) {
    self.init(key: key, defaultValue: nil, container: container)
  }
}

public protocol AnyOptional {
  var isNil: Bool { get }
}

extension Optional: AnyOptional {
  public var isNil: Bool { self == nil }
}
