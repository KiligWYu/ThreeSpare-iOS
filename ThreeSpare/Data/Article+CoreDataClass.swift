//
//  Article+CoreDataClass.swift
//  ThreeSpare
//
//  Created by πΆππππ on 2022/1/12.
//
//

import CoreData
import Foundation

public class Article: NSManagedObject, Decodable {
  enum CodingKeys: String, CodingKey {
    case articleID = "id"
    case title
    case author
    case content
  }

  required convenience public init(from decoder: Decoder) throws {
    self.init(context: Constrant.CoreData.stack.managedContext)

    let container = try decoder.container(keyedBy: CodingKeys.self)
    articleID = try container.decodeIfPresent(String.self, forKey: .articleID) ?? ""
    title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
    author = try container.decodeIfPresent(String.self, forKey: .author) ?? ""
    content = (try container.decodeIfPresent(String.self, forKey: .content) ?? "")
    purify()
    addDate = Date()
    count = Int32(title.count + author.count + content.count)
    summary = content.prefix(100)
      .replacingOccurrences(of: "\n", with: "") + "..."

    print(self)
  }

  private func purify() {
    author = author.replacingOccurrences(of: ".", with: "β’")
    content.regexReplacingOccurrences(of: "</p>|<br>", with: "\n")
    content.regexReplacingOccurrences(of: "<p>|\r|\u{2028}|\u{2029}|\u{0020}", with: "")
    content.regexReplacingOccurrences(of: "\n{2,}", with: "\n")
  }
}

// MARK: -

extension Article {
  public override var description: String {
    """

    IDοΌ\(articleID)
    ε­ζ°οΌ\(count)
    ζ ι’οΌ\(title)
    δ½θοΌ\(author)
    ζ­£ζοΌ
    \(content)

    """
  }
}
