//
//  ArticlesView.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/2/25.
//

import CoreData
import SwiftUI

struct ArticlesView: View {
  private let titleKey = #keyPath(Article.title)
  private let authorKey = #keyPath(Article.author)
  private let summaryKey = #keyPath(Article.summary)
  @State var articles = [NSDictionary]()

  var body: some View {
    List {
      ForEach(articles, id: \.self) { dict in
        NavigationLink {
          if let articleID = dict[#keyPath(Article.articleID)] as? String,
             let title = dict[titleKey] as? String,
             let author = dict[authorKey] as? String {
            ReadHistoryArticleViewControllerWrapper(articleID: articleID)
              .navigationTitle("\(title) - \(author)")
              .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                  Button {
                    NotificationCenter.default.post(name: .init(rawValue: "shareArticleNotification"), object: nil)
                  } label: {
                    Image(systemName: "square.and.arrow.up")
                  }
                }
              }
          }
        } label: {
          VStack(alignment: .center, spacing: 10) {
            Text(dict[titleKey] as? String ?? "")
              .font(.title3)
              .multilineTextAlignment(.center)
            Text(dict[authorKey] as? String ?? "")
              .font(.subheadline)
              .multilineTextAlignment(.center)
            Text(dict[summaryKey] as? String ?? "")
              .font(.body)
              .multilineTextAlignment(.leading)
          }
          .padding(.vertical, 8)
        }
      }
    }
    .listStyle(.plain)
    .onAppear {
      if articles.isEmpty { fetchData() }
    }
    .navigationTitle(articles.count > 0 ? "共 \(articles.count) 篇" : "")
  }
}

// MARK: -

extension ArticlesView {
  private func fetchData() {
    let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Article")
    fetchRequest.resultType = .dictionaryResultType
    fetchRequest.propertiesToFetch = [#keyPath(Article.articleID), titleKey, authorKey, summaryKey]
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "addDate", ascending: false)]
    articles.append(contentsOf: (try? Constrant.CoreData.stack.managedContext.fetch(fetchRequest)) ?? [])
  }
}

// MARK: -

struct ArticlesView_Previews: PreviewProvider {
  static var previews: some View {
    ArticlesView()
  }
}

// MARK: -

struct ReadHistoryArticleViewControllerWrapper: UIViewControllerRepresentable {
  let articleID: String

  func makeUIViewController(context: Context) -> ReadHistoryArticleViewController {
    let viewController = ReadHistoryArticleViewController(articleID: articleID)
    return viewController
  }

  func updateUIViewController(_ uiViewController: ReadHistoryArticleViewController, context: Context) {}
}
