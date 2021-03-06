//
//  UIViewExtension.swift
//  ThreeSpare
//
//  Created by πΆππππ on 2022/1/18.
//

import UIKit

extension UIView {
  func isVisible(in view: UIView) -> Bool {
    view.convert(bounds, from: self)
      .intersects(view.bounds)
  }
}
