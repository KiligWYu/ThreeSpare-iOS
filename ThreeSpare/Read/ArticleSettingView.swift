//
//  ArticleSettingView.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/20.
//

import SwiftUI

struct ArticleSettingView: View {
  @ObservedObject private var viewModel = ArticleSettingViewModel()
  @State private var presentFontPicker = false
  @State private var showGestureTip = false
  @State private var selectedFontIndex = 0

  private func fontSection() -> some View {
    return Section {
      Stepper(value: $viewModel.fontSize, in: 16 ... 40, step: 1) {
        Label("字体大小：\(Int(viewModel.fontSize))", systemImage: "textformat.size.zh")
      }

      HStack {
        Label("字体", systemImage: "character.zh")

        Spacer()

        Picker(selection: $selectedFontIndex, label: Text("")) {
          ForEach(0..<viewModel.fonts.count, id: \.self) { index in
            Text((viewModel.fonts[index].name ?? viewModel.fonts[index].postScriptName) ?? "")
              .tag(index)
          }
        }
        .pickerStyle(.menu)
        .onChange(of: selectedFontIndex) { newValue in
          let name = viewModel.fonts[newValue].postScriptName ?? "系统字体"
          ArticleConfig.fontName = name == "系统字体" ? nil : name
        }
      }

      Button {
        presentFontPicker = true
      } label: {
        Label("导入字体", systemImage: "square.and.arrow.down")
      }
    } header: {
      Text("字体")
    }
  }

  private func spaceSection() -> some View {
    return Section {
      Stepper(value: $viewModel.lineSpacing, in: 0...20, step: 2, label: {
        Label {
          Text("行距")
        } icon: {
          Image("icon_line_spacing")
            .renderingMode(.template)
        }
      })

      Stepper(value: $viewModel.margin, in: 16...40, step: 4, label: {
        Label("边距", systemImage: "rectangle.portrait.arrowtriangle.2.inward")
      })
    } header: {
      Text("间距")
    }
  }

  private func settingSection() -> some View {
    return Section {
      Toggle(isOn: $viewModel.showsVerticalScrollIndicator) {
        Label {
          Text("显示滚动条")
        } icon: {
          Image("icon_scroll_bar")
            .renderingMode(.template)
        }
      }
    } header: {
      Text("滚动条")
    }
  }

  private func tipSection() -> some View {
    Section {
      Button {
        showGestureTip = true
      } label: {
        Label("手势说明", systemImage: "hand.point.up.left")
      }
      .alert("手势说明", isPresented: $showGestureTip) {
        Text("好的")
      } message: {
          Text("在文章页面\n轻点一下以隐藏或显示导航栏；\n轻点两下以加载新一篇文章。")
      }
    }
  }

  var body: some View {
    Form {
      fontSection()
      spaceSection()
      settingSection()
      tipSection()
    }
    .sheet(isPresented: $presentFontPicker) {
      presentFontPicker = false
    } content: {
      FontPicker(fonts: $viewModel.fonts,
                 isPresented: $presentFontPicker)
    }
    .onAppear {
      selectedFontIndex = viewModel.fonts
        .firstIndex(where: { $0.postScriptName == ArticleConfig.fontName }) ?? 0
    }
  }
}

// MARK: -

class ArticleSettingViewModel: ObservableObject {
  private var lastFontSize = ArticleConfig.fontSize

  @Published var showsVerticalScrollIndicator = ArticleConfig.showsVerticalScrollIndicator {
    didSet {
      ArticleConfig.showsVerticalScrollIndicator = showsVerticalScrollIndicator
    }
  }
  @Published var fontSize = ArticleConfig.fontSize {
    didSet {
      fontSizeChanged()
    }
  }
  @Published var lineSpacing = ArticleConfig.lineSpacing {
    didSet {
      print(lineSpacing)
      ArticleConfig.lineSpacing = lineSpacing
    }
  }
  @Published var margin = ArticleConfig.margin {
    didSet {
      print(margin)
      ArticleConfig.margin = margin
    }
  }
  @Published var fonts = FontModel.allRegisteredFonts

  private func fontSizeChanged() {
    if fontSize == lastFontSize { return }
    if fontSize > lastFontSize {
      if fontSize > 36 {
        lastFontSize = 40
        fontSize = 40
      } else if fontSize > 24 {
        lastFontSize += 3
        fontSize += 2
      } else if fontSize > 20 {
        lastFontSize += 2
        fontSize += 1
      }
    } else if fontSize < lastFontSize {
      if fontSize > 36 {
        lastFontSize = 36
        fontSize = 36
      } else if fontSize > 24 {
        lastFontSize -= 3
        fontSize -= 2
      } else if fontSize > 20 {
        lastFontSize -= 2
        fontSize -= 1
      }
    }
    ArticleConfig.fontSize = fontSize
  }
}
