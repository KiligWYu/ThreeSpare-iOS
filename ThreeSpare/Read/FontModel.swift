//
//  FontModel.swift
//  ThreeSpare
//
//  Created by πΆππππ on 2022/1/21.
//

import UIKit

struct FontModel: Identifiable {
  let id = UUID()
  let name: String?
  let postScriptName: String?

  init(name: String?,
       postScriptName: String?) {
    self.name = name
    self.postScriptName = postScriptName
  }

  static func registerFont(path: URL) -> FontModel? {
    guard let data = try? Data(contentsOf: path) as CFData,
          let provider = CGDataProvider(data: data),
          let font = CGFont(provider),
          CTFontManagerRegisterGraphicsFont(font, nil) else {
            BannerView(.error(ThreeSpareError.AppError.RegisterFontError.common)).show()
      return nil
    }
    return FontModel(name: font.fullName as String?,
                     postScriptName: font.postScriptName as String?)
  }

  static let allRegisteredFonts: [FontModel] = {
    var fonts = [FontModel]()
    fonts.append(contentsOf: [
      FontModel(name: "η³»η»ε­δ½",
                postScriptName: "η³»η»ε­δ½")
    ])

    let fileManager = FileManager.default
    let fontsPath = NSHomeDirectory() + "/Documents/Fonts/"
    guard let fontNames = try? fileManager.contentsOfDirectory(atPath: fontsPath) else {
      return fonts
    }

    for name in fontNames {
      if let font = registerFont(path: URL(fileURLWithPath: fontsPath + name)) {
        fonts.append(font)
      }
    }

    return fonts
  }()
}

extension FontModel: Hashable {}

extension FontModel: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.postScriptName == rhs.postScriptName
  }
}

extension FontModel: CustomDebugStringConvertible {
  var debugDescription: String {
    """
    \n
    ε­δ½εη§°οΌ\(self.name ?? "")
    ε­δ½ postScript εη§°οΌ\(self.postScriptName ?? "")
    \n
    """
  }
}
