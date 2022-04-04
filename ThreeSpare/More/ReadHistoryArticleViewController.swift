//
//  ReadHistoryArticleViewController.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/2/26.
//

import CoreData
import UIKit

class ReadHistoryArticleViewController: UIViewController {
  let articleID: String

  @UsesAutoLayout
  private var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    return scrollView
  }()

  @UsesAutoLayout
  private var articleView = HistoryArticleView()
  private var shareNotificationHandler: NSObjectProtocol!

  @UsesAutoLayout
  private var indicatorView: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView()
    view.style = .large
    return view
  }()

  required init(articleID: String) {
    self.articleID = articleID
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    shareNotificationHandler = NotificationCenter.default
      .addObserver(forName: .init(rawValue: "shareArticleNotification"),
                   object: nil,
                   queue: .main) { [weak self] _ in
        guard let `self` = self else { return }
        self.shareAction()
      }

    constructViewHierarchy()
    layoutConstraints()

    fetchArticle()
  }

  deinit {
    NotificationCenter.default.removeObserver(shareNotificationHandler as Any)
  }

  @objc private func shareAction() {
    switch AppConfig.articleShareType {
    case AppConfig.ArticleShareType.ask.rawValue:
      let alertController = UIAlertController(title: "分享格式",
                                              message: "避免生成过大过长图片，长文建议使用 PDF 格式，便于保存和分享，也更加清晰。",
                                              preferredStyle: .actionSheet)
      alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
      alertController.addAction(UIAlertAction(title: "图片", style: .default, handler: { _ in
        self.shareAsPhoto()
      }))
      alertController.addAction(UIAlertAction(title: "PDF", style: .default, handler: { _ in
        self.shareAsPDF()
      }))
      present(alertController, animated: true, completion: nil)
    case AppConfig.ArticleShareType.photo.rawValue:
      shareAsPhoto()
    case AppConfig.ArticleShareType.pdf.rawValue:
      shareAsPDF()
    default:
      break
    }
  }

  private func shareAsPhoto() {
    indicatorView.startAnimating()

    UIGraphicsBeginImageContextWithOptions(articleView.bounds.size, true, UIScreen.main.scale)
    guard let context = UIGraphicsGetCurrentContext() else {
      indicatorView.stopAnimating()
      return
    }
    articleView.layer.render(in: context)
    guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
      indicatorView.stopAnimating()
      return
    }
    UIGraphicsEndImageContext()

    let activityVC = UIActivityViewController(activityItems: [image],
                                              applicationActivities: nil)
    present(activityVC, animated: true) {
      self.indicatorView.stopAnimating()
    }
  }

  private func shareAsPDF() {
    guard let title = articleView.articleData?.article?.title,
          let author = articleView.articleData?.article?.author else {
      return
    }

    indicatorView.startAnimating()

    var data: NSMutableData?
    let fileName = "\(title) - \(author).pdf"
    let path = NSTemporaryDirectory() + "/\(fileName)"
    if FileManager.default.fileExists(atPath: path) {
      data = NSMutableData(contentsOf: URL(fileURLWithPath: path))
    } else {
      let pdfData = NSMutableData()
      UIGraphicsBeginPDFContextToData(pdfData, articleView.bounds, nil)
      UIGraphicsBeginPDFPage()
      guard let context = UIGraphicsGetCurrentContext() else { return }
      articleView.layer.render(in: context)
      UIGraphicsEndPDFContext()

      if pdfData.write(toFile: path, atomically: true) {
        data = pdfData
      }
    }

    guard data != nil else {
      indicatorView.stopAnimating()
      BannerView(.error(ThreeSpareError.AppError.Reading.generatePDFFail)).show()
      return
    }
    let activityVC = UIActivityViewController(activityItems: [URL(fileURLWithPath: path)],
                                              applicationActivities: nil)
    present(activityVC, animated: true) {
      self.indicatorView.stopAnimating()
    }
  }

  private func fetchArticle() {
    indicatorView.startAnimating()

    let idKey = #keyPath(Article.articleID)
    let fetchRequest = Article.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "%K == %@", idKey, articleID)
    if let article = try? Constrant.CoreData.stack.managedContext.fetch(fetchRequest).first {
      DispatchQueue.main.async {
        let articleData = ArticleParser.parse(article: article)
        self.articleView.articleData = articleData
        self.articleView.heightAnchor.constraint(equalToConstant: articleData.height ?? 0)
          .isActive = true

        self.indicatorView.stopAnimating()
      }
    }
  }
}

// MARK: -

extension ReadHistoryArticleViewController: Constructable {
  func constructViewHierarchy() {
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.contentInset = UIEdgeInsets(top: Constrant.App.statusBarHeight,
                                           left: 0,
                                           bottom: tabBarController?.tabBar.bounds.height ?? 0,
                                           right: 0)
    scrollView.showsVerticalScrollIndicator = ArticleConfig.showsVerticalScrollIndicator
    scrollView.delegate = self
    scrollView.addSubview(articleView)
    view.addSubview(scrollView)
    view.addSubview(indicatorView)
  }

  func layoutConstraints() {
    NSLayoutConstraint.activate([
      articleView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      articleView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      articleView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      articleView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      articleView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -60),

      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      indicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      indicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      indicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      indicatorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }
}

// MARK: -

extension ReadHistoryArticleViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.height,
          let article = articleView.articleData?.article,
          article.readDate == nil
    else {
      return
    }

    if AppConfig.lastArticleID == articleID {
      AppConfig.isLastArticleReaded = true
    }
    article.readDate = Date()
    Constrant.CoreData.stack.saveContext()
    print("article readed.")
  }
}

// MARK: -

private class HistoryArticleView: UIView {
  var articleData: ArticleData? {
    didSet {
      guard articleData != nil else {
        return
      }
      setNeedsDisplay()
    }
  }

  override class var layerClass: AnyClass {
    TiledLayer.self
  }

  override init(frame: CGRect) {
    super.init(frame: .zero)

    backgroundColor = .systemBackground
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext(),
          let height = articleData?.height,
          let frame = articleData?.frameRef
    else { return }

    context.textMatrix = .identity
    context.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: height))
    CTFrameDraw(frame, context)
  }
}
