//
//  DataProvider.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/3/4.
//

import Combine
import CoreData
import Foundation

class DataProvider {
  static let shared = DataProvider()

  private var cancellables = Set<AnyCancellable>()

  var articleSubject = PassthroughSubject<ArticleData, Never>()

  var monthData = PassthroughSubject<[[String: Int]], Never>()
  var lastMonthReadAmount = PassthroughSubject<Int, Never>()

  private init() {}
}

// MARK: -

extension DataProvider {
  func getRandomArticle() {
    let url = NetworkURL.getRandomArticle.url
    let model = APIManager<Article>.Model(url: url, method: .get)

    APIManager.shared.request(with: model)
      .sink { completion in
        switch completion {
        case .finished:
          break
        case .failure(let error):
          print(error)
        }
      } receiveValue: { article in
        self.articleSubject.send(ArticleParser.parse(article: article))
        Constrant.CoreData.stack.saveContext()
      }
      .store(in: &cancellables)
  }

  func getLastArticle(with articleID: String) {
    let fetchRequest = Article.fetchRequest()
    fetchRequest.predicate =
      NSPredicate(format: "%K == %@", #keyPath(Article.articleID), articleID)
    if let article = try? Constrant.CoreData.stack.managedContext.fetch(fetchRequest).first {
      articleSubject.send(ArticleParser.parse(article: article))
    } else {
      getRandomArticle()
    }
  }
}

extension DataProvider {
  func fetchCurrentMonthData() {
    let countKey = #keyPath(Article.count)
    let dateKey = #keyPath(Article.readDate)

    let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Article")
    let calendar = Calendar.current
    let endDate = Date()
    let startDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -27, to: endDate)!)
    let predicate =
    NSPredicate(format: "%K >= %@ AND %K < %@",
                dateKey,
                startDate as NSDate,
                dateKey,
                endDate as NSDate)

    fetchRequest.predicate = predicate
    fetchRequest.resultType = .dictionaryResultType
    fetchRequest.propertiesToFetch = [#keyPath(Article.readDate), #keyPath(Article.count)]
    if let results = try? Constrant.CoreData.stack.managedContext.fetch(fetchRequest) {
      let dateFormatter = DateFormatter.formate("y-M-d")
      var resultDict = [String: Int]()
      results.forEach { dict in
        // swiftlint:disable force_cast
        let dateString = dateFormatter.string(from: dict[dateKey] as! Date)
        resultDict[dateString] = (resultDict[dateString] ?? 0) + (dict[countKey] as! Int)
        // swiftlint:enable force_cast
      }

      var formattedResults = [[String: Int]]()
      for index in 0 ..< 28 {
        let key = dateFormatter.string(from: endDate.advanced(by: -Double(index) * 24 * 60 * 60))
        let value = resultDict[key] ?? 0
        formattedResults.insert([key: value], at: 0)
      }
      let dayOfWeek = Date().dayOfWeek()
      if dayOfWeek != 7 {
        formattedResults.append(contentsOf: [[String: Int]](repeating: ["": 0], count: 7 - dayOfWeek))
        formattedResults.insert(contentsOf: [[String: Int]](repeating: ["": 0], count: dayOfWeek), at: 0)
      }
      monthData.send(formattedResults)
    } else {
      monthData.send([])
    }
  }

  func fetchLastMonthData() {
    let countKey = #keyPath(Article.count)
    let dateKey = #keyPath(Article.readDate)

    let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Article")
    let calendar = Calendar.current
    let endDate = calendar.startOfDay(for: Date().advanced(by: -28 * 24 * 60 * 60))
    let startDate = calendar.date(byAdding: .day, value: -27, to: endDate)!
    let predicate =
    NSPredicate(format: "%K >= %@ AND %K < %@",
                dateKey,
                startDate as NSDate,
                dateKey,
                endDate as NSDate)

    fetchRequest.predicate = predicate
    fetchRequest.resultType = .dictionaryResultType
    fetchRequest.propertiesToFetch = [#keyPath(Article.count)]
    if let results = try? Constrant.CoreData.stack.managedContext.fetch(fetchRequest) {
      let lastMonthTotal = results.compactMap {
        $0[countKey] as? Int
      }
        .reduce(0, +)
      lastMonthReadAmount.send(lastMonthTotal)
    } else {
      lastMonthReadAmount.send(0)
    }
  }
}
