//
//  UsesAutoLayout.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/13.
//

import Foundation
import UIKit

@propertyWrapper
struct UsesAutoLayout<Property: UIView> {
  var wrappedValue: Property {
    didSet {
      wrappedValue.translatesAutoresizingMaskIntoConstraints = false
    }
  }

  init(wrappedValue: Property) {
    self.wrappedValue = wrappedValue
    wrappedValue.translatesAutoresizingMaskIntoConstraints = false
  }
}
