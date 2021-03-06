//
//  UsesAutoLayout.swift
//  ThreeSpare
//
//  Created by πΆππππ on 2022/1/13.
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
