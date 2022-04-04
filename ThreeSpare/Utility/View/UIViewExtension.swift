//
//  UIViewExtension.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/18.
//

import UIKit

extension UIView {
  func isVisible(in view: UIView) -> Bool {
    view.convert(bounds, from: self)
      .intersects(view.bounds)
  }
}
