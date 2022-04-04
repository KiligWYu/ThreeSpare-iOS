//
//  MoreView.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/2/24.
//

import SwiftUI

struct MoreView: View {
  @State private var showingPrivacyAlert = false
  @State private var showingShareSheet = false

  var body: some View {
    NavigationView {
      Form {
        articleSection()
        supportSection()
        ourAppsSection()
        moreSection()
        footerSection()
      }
      .navigationBarTitleDisplayMode(.large)
      .navigationTitle("更多")
    }
    .alert(isPresented: $showingPrivacyAlert, content: { // 隐私政策
      Alert(title: Text("隐私政策"),
            message: Text("我们非常在意您的隐私，我们不收集任何数据！"),
            dismissButton: .cancel(Text("好的")))
    })
  }

  private func articleSection() -> some View {
    Section {
      NavigationLink {
        ArticlesView()
          .navigationBarTitleDisplayMode(.inline)
      } label: {
        Label("所有文章", systemImage: "doc.append")
          .foregroundColor(.accentColor)
      }
    } header: {
      Text("阅读历史")
    }
  }

  private func supportSection() -> some View {
    Section(header: Text("关于")) {
      Button(action: contactDeveloper, label: {
        Label("欢迎反馈", systemImage: "envelope")
      })

      Button {
        showingPrivacyAlert.toggle()
      } label: {
        Label("隐私政策", systemImage: "checkmark.shield")
      }
    }
  }

  private func ourAppsSection() -> some View {
    Section(header: Text("更多应用")) {
      Button {
        let url = Constrant.moreByDeveloperURL
        if UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url)
        }
      } label: {
        Label("我们的应用", image: "icon_app-store")
      }
    }
  }

  private func moreSection() -> some View {
    Section(header: Text("更多")) {
      NavigationLink {
        AboutThreeSpareView()
          .navigationTitle("三余")
          .navigationBarTitleDisplayMode(.inline)
      } label: {
        Label("关于三余", systemImage: "doc.plaintext")
          .foregroundColor(.accentColor)
      }

      Button {
        let url = URL(string: "https://meiriyiwen.com/index/about")!
        if UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url)
        }
      } label: {
        Label("关于每日一文", systemImage: "link")
      }

      Button(action: contactOfficial) {
        Label("联系每日一文", systemImage: "envelope")
      }
    }
  }

  private func footerSection() -> some View {
    Section {
    } footer: {
      HStack {
        Spacer()
        Text("Version \(Constrant.App.version)\n✨ Made with ♥️ by Kilig ✨")
          .font(.footnote)
          .multilineTextAlignment(.center)
        Spacer()
      }
    }
  }

  private func contactDeveloper() {
    let feedbackURL: URL = {
      let subject = ("三余 \(Constrant.App.version)(\(Constrant.App.build))"
                     + " \(UIDevice.current.model) \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
      ).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
      let urlString = "mailto:KiligLab@outlook.com?subject=\(subject)"
      return URL(string: urlString)!
    }()
    UIApplication.shared.open(feedbackURL)
  }

  private func contactOfficial() {
    let contactURL = URL(string: "mailto:contact@meiriyiwen.com")!
    UIApplication.shared.open(contactURL)
  }
}

struct MoreView_Previews: PreviewProvider {
  static var previews: some View {
    MoreView()
  }
}
