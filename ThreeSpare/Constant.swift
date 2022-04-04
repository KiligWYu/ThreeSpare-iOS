//
//  Constant.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/12.
//

import Foundation
import UIKit

struct Constrant {
  // MARK: - App
  enum App {
    static var statusBarHeight: CGFloat {
      UIApplication.shared
        .connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .filter { $0.isKeyWindow }
        .first?
        .windowScene?
        .statusBarManager?
        .statusBarFrame
        .height ?? 0
    }

    /// System animation duration
    static let animationDuration = UINavigationController.hideShowBarDuration

    // swiftlint:disable:next force_cast
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    // swiftlint:disable:next force_cast
    static let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
  }

  // MARK: -

  /// Our apps preview in App Store
  static let moreByDeveloperURL = URL(string: "https://apps.apple.com/developer/id1225020202")!

  // MARK: - CoreData

  enum CoreData {
    static let stack = CoreDataStack(modelName: "Article")
  }
}
