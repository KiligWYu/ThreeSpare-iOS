//
//  ArticleViewModel.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/15.
//

import Foundation
import UIKit
import Combine

class ArticleViewModel: ObservableObject {
  private var cancellables = Set<AnyCancellable>()

  var article: Article?
  var articleData = PassthroughSubject<ArticleData, Never>()

  var isLoading = PassthroughSubject<Bool, Never>()
  var toggleBarHidden = PassthroughSubject<Void, Never>()

  var error = Observable<ThreeSpareError.Request>()
  private var config = PassthroughSubject<Void, Never>()

  init() {
    DataProvider.shared.articleSubject.sink { articleData in
      AppConfig.lastArticleID = articleData.article?.articleID
      self.article = articleData.article
      self.articleData.send(articleData)
      self.isLoading.send(false)
    }
    .store(in: &cancellables)

    config.sink { [weak self] _ in
      guard let `self` = self, let article = self.article else { return }

      self.articleData.send(ArticleParser.parse(article: article))
    }
    .store(in: &cancellables)

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(articleConfigChangedHandler(_:)),
                                           name: .articleConfigChanged,
                                           object: nil)
  }

  func loadArticle(isLast: Bool = false) {
    isLoading.send(true)

    if !isLast {
      DataProvider.shared.getRandomArticle()
    } else if let articleID = AppConfig.lastArticleID, !AppConfig.isLastArticleReaded {
      DataProvider.shared.getLastArticle(with: articleID)
    } else {
      DataProvider.shared.getRandomArticle()
    }
  }

  func toggleFav() -> Bool {
    guard article != nil else { return false }

    article?.isFav.toggle()
    Constrant.CoreData.stack.saveContext()

    return article?.isFav ?? false
  }

  @objc private func articleConfigChangedHandler(_ sender: Any) {
    config.send()
  }
}
