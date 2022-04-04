//
//  BannerView.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/19.
//

import UIKit

class BannerView: UIView {
  enum BannerType {
    case message(String)
    case success(String)
    case warning(String)
    case error(Error)
  }

  private let bannerType: BannerType
  private let bannerShowTime: TimeInterval = 3
  @UsesAutoLayout
  private var messageLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: UIFont.systemFontSize, weight: .medium)
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()

  private let feedbackGenerator = UINotificationFeedbackGenerator()

  required init(_ type: BannerType) {
    self.bannerType = type
    super.init(frame: .zero)

    feedbackGenerator.prepare()
    translatesAutoresizingMaskIntoConstraints = false
    addSubview(messageLabel)
    switch type {
    case .message(let message):
      messageLabel.text = message
      messageLabel.textColor = .label
      backgroundColor = .systemBackground
    case .success(let message):
      messageLabel.text = message
      messageLabel.textColor = .white
      backgroundColor = .systemGreen
    case .warning(let message):
      messageLabel.text = message
      messageLabel.textColor = .black
      backgroundColor = .systemYellow
    case .error(let error):
      messageLabel.text = error.localizedDescription
      messageLabel.textColor = .white
      backgroundColor = .systemRed
    }

    let messageLabelTopMargin =
      Constrant.App.statusBarHeight == 20 ? 36 : Constrant.App.statusBarHeight
    NSLayoutConstraint.activate([
      messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
      messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
      messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
      messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: messageLabelTopMargin),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func show() {
    guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else {
      return
    }

    window.addSubview(self)
    window.setNeedsLayout()
    let bottomAnchor = self.bottomAnchor.constraint(equalTo: window.topAnchor)
    bottomAnchor.isActive = true
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: window.leadingAnchor),
      trailingAnchor.constraint(equalTo: window.trailingAnchor),
    ])
    window.layoutIfNeeded()

    switch bannerType {
    case .message:
      break
    case .success:
      feedbackGenerator.notificationOccurred(.success)
    case .warning:
      feedbackGenerator.notificationOccurred(.warning)
    case .error:
      feedbackGenerator.notificationOccurred(.error)
    }

    bottomAnchor.constant = bounds.height
    UIView.animate(withDuration: Constrant.App.animationDuration,
                   delay: 0,
                   usingSpringWithDamping: 0.5,
                   initialSpringVelocity: 10,
                   options: .allowUserInteraction) {
      window.layoutIfNeeded()
    } completion: { completion in
      guard completion == true else { return }

      bottomAnchor.constant = 0
      UIView.animate(withDuration: Constrant.App.animationDuration,
                     delay: self.bannerShowTime,
                     options: .curveEaseOut) {
        window.layoutIfNeeded()
      } completion: { completion in
        guard completion == true else { return }
        self.removeFromSuperview()
      }
    }
  }
}
