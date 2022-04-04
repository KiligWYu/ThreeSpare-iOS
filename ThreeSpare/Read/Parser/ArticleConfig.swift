//
//  ArticleConfig.swift
//  iCollectDataKit
//
//  Created by wy on 2019-05-07.
//  Copyright © 2019 KiligWYu. All rights reserved.
//

import UIKit

public enum ArticleConfig {
  private static let articleContainer = UserDefaults(suiteName: "com.KiligWYu.ThreeSpare.Article")!

  @UserDefault(key: ArticleConfigKey.lineSpacing,
               defaultValue: 10,
               container: articleContainer)
  static var lineSpacing: CGFloat { didSet { configChanged() } }

  @UserDefault(key: ArticleConfigKey.fontSize,
               defaultValue: 18,
               container: articleContainer)
  static var fontSize: CGFloat { didSet { configChanged() } }

  @UserDefault(key: ArticleConfigKey.fontName, articleContainer)
  static var fontName: String? { didSet { configChanged() } }

  @UserDefault(key: ArticleConfigKey.showVerticalScrollIndicator,
               defaultValue: false,
               container: articleContainer)
  static var showsVerticalScrollIndicator: Bool {
    didSet {
      NotificationCenter.default.post(name: .showsVerticalScrollIndicatorChanged, object: nil)
    }
  }

  @UserDefault(key: ArticleConfigKey.margin,
               defaultValue: 20,
               container: articleContainer)
  static var margin: CGFloat { didSet { configChanged() } }

  public static var titleFont: UIFont {
    let size = ArticleConfig.fontSize + 8
    guard let fontName = fontName,
          let font = UIFont(name: fontName, size: size)
    else {
      return .systemFont(ofSize: size)
    }
    return font
  }

  public static var authorFont: UIFont {
    let size = fontSize - 3
    guard let fontName = fontName,
          let font = UIFont(name: fontName, size: size)
    else {
      return .systemFont(ofSize: size)
    }
    return font
  }

  public static var contentFont: UIFont {
    let size = fontSize
    guard let fontName = fontName,
          let font = UIFont(name: fontName, size: size)
    else {
      return .systemFont(ofSize: size)
    }
    return font
  }

  public static let textColor = UIColor.label

  public static let topMargin: CGFloat = 80 - Constrant.App.statusBarHeight
  public static let bottomMargin: CGFloat = 80

  public static var titleParagraphStyle: NSParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    style.lineSpacing = lineSpacing
    return style
  }

  public static var authorParagraphStyle: NSParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    style.lineSpacing = lineSpacing / 2
    return style
  }

  private static var headIndent: CGFloat {
    let width = "缩进"
      .boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
                    options: .usesLineFragmentOrigin,
                    attributes: [.font: ArticleConfig.contentFont,
                                 .foregroundColor: ArticleConfig.textColor,
                                 .paragraphStyle: {
                                   let style = NSMutableParagraphStyle()
                                   style.alignment = .justified
                                   style.lineSpacing = lineSpacing
                                   return style
                                 }()],
                    context: nil)
      .width
    return CGFloat(ceilf(Float(width)))
  }

  public static var contentParagraphStyle: NSParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.alignment = .justified
    style.lineSpacing = lineSpacing
    style.firstLineHeadIndent = headIndent
    return style
  }

  private static func configChanged() {
    NotificationCenter.default.post(name: .articleConfigChanged, object: nil)
  }
}

// MARK: -

public extension ArticleConfig {
  static let lineSpacingRange: ClosedRange<CGFloat> = 0...20
  static let marginRange: ClosedRange<CGFloat> = 16...40
}

// MARK: -

private enum ArticleConfigKey {
  static let fontName = "Article.FontNameKey"
  static let fontSize = "Article.FontSizeKey"
  static let lineSpacing = "Article.LineSpacingKey"
  static let showVerticalScrollIndicator = "Article.ShowVerticalScrollIndicatorKey"
  static let margin = "Article.MarginKey"
}

// MARK: -

extension Notification.Name {
  static let articleConfigChanged = Self("articleConfigChanged")
  static let showsVerticalScrollIndicatorChanged = Self("showsVerticalScrollIndicatorChanged")
}
