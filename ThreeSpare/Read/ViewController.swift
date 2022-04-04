//
//  ViewController.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2021/12/28.
//

import Combine
import CoreData
import SwiftUI
import UIKit

class ViewController: UIViewController {
  @UsesAutoLayout
  private var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    return scrollView
  }()

  private var viewModel = ArticleViewModel()
  private lazy var articleView = ArticleView(viewModel)
  private var articleViewHeightAnchor: NSLayoutConstraint?

  private lazy var readMoreButton: UIButton = {
    let button = UIButton(
      type: .roundedRect, primaryAction: UIAction { [weak self] _ in
        guard let `self` = self else { return }
        self.viewModel.loadArticle()
      })
    button.setTitle("再读一篇", for: .normal)
    button.isHidden = true
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.borderWidth = 0.5
    button.layer.borderColor = button.tintColor.cgColor
    button.layer.cornerRadius = 10
    button.layer.masksToBounds = true
    return button
  }()

  @UsesAutoLayout
  private var indicatorView: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView()
    view.style = .large
    return view
  }()

  private var notificationObserver: NSObjectProtocol?
  private var cancellables = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()

    defer {
      viewModel.loadArticle(isLast: true)
    }

    view.backgroundColor = .systemBackground

    constructViewHierarchy()
    layoutConstraints()

    notificationObserver = NotificationCenter.default.addObserver(
      forName: .showsVerticalScrollIndicatorChanged,
      object: nil, queue: .main, using: { [weak self] _ in
        guard let `self` = self else { return }
        self.scrollView.showsVerticalScrollIndicator = ArticleConfig.showsVerticalScrollIndicator
      })

    viewModel.articleData.sink { [weak self] articleData in
      guard let `self` = self else { return }
      self.setupNavigationBar()
      self.readMoreButton.isHidden = false

      self.articleViewHeightAnchor?.isActive = false
      self.articleViewHeightAnchor = self.articleView.heightAnchor.constraint(equalToConstant: articleData.height ?? 0)
      self.articleViewHeightAnchor?.isActive = true

      self.scrollView.delegate = nil
      UIView.animate(withDuration: Constrant.App.animationDuration) {
        self.scrollView.contentOffset = CGPoint(x: 0, y: -self.scrollView.contentInset.top)
      } completion: { completion in
        guard completion else { return }
        self.scrollView.delegate = self
      }
    }
    .store(in: &cancellables)

    viewModel.isLoading.sink { [weak self] isLoading in
      guard let `self` = self else { return }
      isLoading ? self.indicatorView.startAnimating() : self.indicatorView.stopAnimating()
    }
    .store(in: &cancellables)

    viewModel.toggleBarHidden.sink { [weak self] _ in
      guard let `self` = self else { return }
      self.toggleTabBarHidden()
      self.toggleNavigationBarHidden()
    }
    .store(in: &cancellables)
  }

  deinit {
    if let observer = notificationObserver {
      NotificationCenter.default.removeObserver(observer as Any)
    }
  }

  private func setupNavigationBar() {
    if navigationItem.leftBarButtonItem.isNil {
      navigationItem.leftBarButtonItem =
        UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                        style: .plain,
                        target: self,
                        action: #selector(shareHandler(_:)))
    }

    if navigationItem.rightBarButtonItem.isNil {
      navigationItem.rightBarButtonItem =
        UIBarButtonItem(image: UIImage(systemName: "textformat.size.zh"),
                        style: .plain,
                        target: self,
                        action: #selector(settingHandler(_:)))
    }
  }

  @objc private func settingHandler(_ sender: AnyObject) {
    let settingVC = UIHostingController(rootView: ArticleSettingView())
    if let sheet = settingVC.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.prefersGrabberVisible = true
    }
    present(settingVC, animated: true)
  }

  @objc private func shareHandler(_ sender: AnyObject) {
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

  @objc private func favHandler(_ sender: UIBarButtonItem) {
    let isFav = viewModel.toggleFav()
    sender.image = UIImage(systemName: isFav ? "heart.fill" : "heart")
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
    guard let title = viewModel.article?.title,
          let author = viewModel.article?.author else {
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
}

// MARK: -

extension ViewController: Constructable {
  func constructViewHierarchy() {
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.contentInset = UIEdgeInsets(top: Constrant.App.statusBarHeight,
                                           left: 0,
                                           bottom: tabBarController?.tabBar.bounds.height ?? 0,
                                           right: 0)
    scrollView.showsVerticalScrollIndicator = ArticleConfig.showsVerticalScrollIndicator
    scrollView.delegate = self
    scrollView.addSubview(articleView)
    scrollView.addSubview(readMoreButton)
    view.addSubview(scrollView)
    view.addSubview(indicatorView)
  }

  func layoutConstraints() {
    articleView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      articleView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      articleView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      articleView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      articleView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),

      readMoreButton.topAnchor.constraint(equalTo: articleView.bottomAnchor),
      readMoreButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
      readMoreButton.heightAnchor.constraint(equalToConstant: 40),
      readMoreButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
      readMoreButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.5),

      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constrant.App.statusBarHeight),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      indicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      indicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      indicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      indicatorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }
}

// MARK: -

extension ViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if !readMoreButton.isHidden,
       readMoreButton.isVisible(in: view),
       let article = articleView.articleData?.article,
       article.readDate == nil {
      AppConfig.isLastArticleReaded = true
      article.readDate = Date()
      Constrant.CoreData.stack.saveContext()
      print("article readed.")
    }
  }
}
