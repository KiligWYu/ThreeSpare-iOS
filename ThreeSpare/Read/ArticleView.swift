//
//  ArticleView.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/15.
//

import UIKit
import Combine

class ArticleView: UIView {
  override class var layerClass: AnyClass {
    TiledLayer.self
  }

  private var cancellables = Set<AnyCancellable>()

  var articleData: ArticleData? {
    didSet {
      guard articleData != nil else {
        return
      }
      self.setNeedsDisplay()
    }
  }

  let viewModel: ArticleViewModel

  required init(_ viewModel: ArticleViewModel) {
    self.viewModel = viewModel
    super.init(frame: .zero)

    backgroundColor = .systemBackground

    let doubleTapGesture = UITapGestureRecognizer(target: self,
                                               action: #selector(doubleGestureHandler(_:)))
    doubleTapGesture.numberOfTapsRequired = 2
    addGestureRecognizer(doubleTapGesture)

    let tapGesture = UITapGestureRecognizer(target: self,
                                            action: #selector(tapGestureHandler(_:)))
    tapGesture.numberOfTapsRequired = 1
    tapGesture.require(toFail: doubleTapGesture)
    addGestureRecognizer(tapGesture)

    viewModel.articleData.sink { articleData in
      self.articleData = articleData
    }
    .store(in: &cancellables)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 双击手势处理：加载另外一篇文章
  /// - Parameter sender: 双击手势
  @objc private func doubleGestureHandler(_ sender: UITapGestureRecognizer) {
    guard sender.state == .ended else { return }

    viewModel.loadArticle()
  }

  @objc private func tapGestureHandler(_ sender: UITapGestureRecognizer) {
    guard sender.state == .ended else { return }

    viewModel.toggleBarHidden.send()
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

// MARK: -

class TiledLayer: CATiledLayer {
  override class func fadeDuration() -> CFTimeInterval { 0 }
}
