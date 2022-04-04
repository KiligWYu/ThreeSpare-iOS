//
//  AppConfig.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/18.
//

import Foundation

struct AppConfig {
  private static let appContainer = UserDefaults(suiteName: "com.KiligWYu.ThreeSpare.App")!

  @UserDefault(key: AppConfigKey.lastArticleID,
               appContainer)
  static var lastArticleID: String?

  @UserDefault(key: AppConfigKey.isLastArticleReaded,
               defaultValue: false,
               container: appContainer)
  static var isLastArticleReaded: Bool

  enum ArticleShareType: Int {
    case ask
    case photo
    case pdf
  }

  @UserDefault(key: AppConfigKey.articleShareType,
               defaultValue: ArticleShareType.ask.rawValue,
               container: appContainer)
  static var articleShareType: ArticleShareType.RawValue
}

// MARK: -

private enum AppConfigKey {
  static let lastArticleID = "App.LastArticleIDKey"
  static let isLastArticleReaded = "App.IsLastArticleReadedKey"
  static let articleShareType = "App.ArticleShareTypeKey"
}
