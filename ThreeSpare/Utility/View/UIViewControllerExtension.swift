//
//  UIViewControllerExtension.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/20.
//

import UIKit

extension UIViewController {
  func toggleTabBarHidden() {
    let animationDuration = UINavigationController.hideShowBarDuration
    UIView.animate(withDuration: animationDuration, animations: {
      self.tabBarController?.tabBar.alpha = 1 - (self.tabBarController?.tabBar.alpha ?? 1)
    })
  }

  func toggleNavigationBarHidden() {
    let animationDuration = UINavigationController.hideShowBarDuration
    UIView.animate(withDuration: animationDuration, animations: {
      self.navigationController?.navigationBar.alpha = 1 - (self.navigationController?.navigationBar.alpha ?? 1)
    })
  }
}
