//
//  Article+CoreDataProperties.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/12.
//
//

import CoreData
import Foundation
import UIKit

public extension Article {
  @nonobjc class func fetchRequest() -> NSFetchRequest<Article> {
    return NSFetchRequest<Article>(entityName: "Article")
  }

  @NSManaged var articleID: String
  @NSManaged var title: String
  @NSManaged var author: String
  @NSManaged var content: String
  @NSManaged var isFav: Bool
  @NSManaged var addDate: Date?
  @NSManaged var readDate: Date?
  @NSManaged var count: Int32
  @NSManaged var summary: String
}

extension Article: Identifiable {}

extension Article {
  public override var debugDescription: String {
    """
    articleID: \(articleID)
    title: \(title)
    author: \(author)
    content: \(content)
    isFav: \(isFav)
    addDate: \(String(describing: addDate))
    readDate: \(String(describing: readDate))

    """
  }
}
