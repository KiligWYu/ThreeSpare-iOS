//
//  TabBarController.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/12.
//

import UIKit
import SwiftUI

class TabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let articleController = UINavigationController(rootViewController: ViewController())
    articleController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "doc.append"), tag: 0)

    let statisticsController =
      UINavigationController(rootViewController: UIHostingController(rootView: StatisticsView()))
    statisticsController.navigationBar.prefersLargeTitles = true
    statisticsController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "chart.bar.xaxis"), tag: 1)

    let moreController = UIHostingController(rootView: MoreView())
    moreController.hidesBottomBarWhenPushed = true
    moreController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "ellipsis"), tag: 2)

    viewControllers = [articleController, statisticsController, moreController]
  }
}
