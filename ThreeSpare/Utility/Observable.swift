//
//  Observable.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/17.
//

import Foundation

class Observable<T> {
  typealias Listener = (T?) -> Void

  var value: T? {
    didSet {
      listeners.forEach {
        $0(value)
      }
    }
  }

  private var listeners: [Listener] = []

  init(_ value: T? = nil) {
    self.value = value
  }

  func bind(_ listener: @escaping Listener) {
    listeners.append(listener)
    listener(value)
  }
}
