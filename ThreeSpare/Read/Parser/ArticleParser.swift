//
//  ArticleParser.swift
//  DailyRead
//
//  Created by devwy on 2017/1/7.
//  Copyright © 2017年 devwy. All rights reserved.
//

import UIKit

public struct ArticleParser {
  private init() {}

  public static func parse(article: Article) -> ArticleData {
    let string = "\(article.title)\n\n\(article.author)\n\n\(article.content)"
    let attStr = NSMutableAttributedString(string: string)

    let titleLength = article.title.count
    let authorLength = article.author.count + 4
    let contentLength = article.content.count

    // 标题和作者
    attStr.addAttributes([.font: ArticleConfig.titleFont,
                          .foregroundColor: ArticleConfig.textColor,
                          .paragraphStyle: ArticleConfig.titleParagraphStyle],
                         range: NSRange(location: 0, length: titleLength))
    attStr.addAttributes([.font: ArticleConfig.authorFont,
                          .foregroundColor: ArticleConfig.textColor,
                          .paragraphStyle: ArticleConfig.authorParagraphStyle],
                         range: NSRange(location: titleLength, length: authorLength))
    // 正文
    attStr.addAttributes([.font: ArticleConfig.contentFont,
                          .foregroundColor: ArticleConfig.textColor,
                          .paragraphStyle: ArticleConfig.contentParagraphStyle],
                         range: NSRange(location: titleLength + authorLength, length: contentLength))

    let margin: CGFloat = ArticleConfig.margin
    let width = UIScreen.main.bounds.width - margin * 2
    let framesetter = CTFramesetterCreateWithAttributedString(attStr)
    let size = CTFramesetterSuggestFrameSizeWithConstraints(
      framesetter,
      CFRangeMake(0, 0),
      nil,
      CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
      nil)
    let height = size.height + ArticleConfig.topMargin + ArticleConfig.bottomMargin
    let path = CGMutablePath()
    path.addRect(CGRect(x: margin,
                        y: -ArticleConfig.topMargin,
                        width: width,
                        height: height))
    let ctFrame = CTFramesetterCreateFrame(framesetter,
                                           CFRangeMake(0, attStr.length),
                                           path,
                                           nil)

    return ArticleData(frameRef: ctFrame,
                       height: height,
                       article: article)
  }
}
