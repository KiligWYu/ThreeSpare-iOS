//
//  FontPicker.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/21.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct FontPicker: UIViewControllerRepresentable {
  @Binding var fonts: [FontModel]
  @Binding var isPresented: Bool

  func makeUIViewController(context: Context) -> some UIViewController {
    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.font], asCopy: true)
    picker.shouldShowFileExtensions = true
    picker.allowsMultipleSelection = true
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func registerFonts(_ urls: [URL]) {
    var registerStatus = [Bool](repeating: false, count: urls.count)
    var registerFontError: ThreeSpareError.AppError.RegisterFontError?

    defer {
      let successedCount = registerStatus.filter { $0 }.count
      if registerStatus.count == successedCount {
        BannerView(.success("导入字体成功")).show()
      } else if successedCount == 0 {
        if let registerFontError = registerFontError {
          BannerView(.error(registerFontError)).show()
        } else {
          BannerView(.error(ThreeSpareError.AppError.RegisterFontError.common)).show()
        }
      } else {
        BannerView(
          .warning("\(successedCount) 个字体导入成功\n\(registerStatus.count - successedCount) 个字体导入失败")
        ).show()
      }
    }

    for (index, path) in urls.enumerated() {
      let fileManager = FileManager.default
      let savePath = NSHomeDirectory() + "/Documents/Fonts/"
      var isDirectory = ObjCBool(true)
      if !fileManager.fileExists(atPath: savePath, isDirectory: &isDirectory) {
        do {
          try fileManager.createDirectory(atPath: savePath, withIntermediateDirectories: false, attributes: nil)
        } catch {
          registerFontError = .createDirectoryFail
          continue
        }
      }
      if fileManager.fileExists(atPath: savePath + path.lastPathComponent) {
        registerFontError = .fontExist
        continue
      }

      let savePathURL = URL(fileURLWithPath: savePath + path.lastPathComponent)
      do {
        try fileManager.copyItem(at: path, to: savePathURL)
      } catch {
        registerFontError = .copyFontFileFail
        continue
      }

      if let newFont = FontModel.registerFont(path: savePathURL) {
        fonts.append(newFont)
        registerStatus[index] = true
      }
    }
  }

  class Coordinator: NSObject, UIDocumentPickerDelegate {
    let picker: FontPicker

    init(_ picker: FontPicker) {
      self.picker = picker
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      defer {
        self.picker.isPresented = false
      }

      picker.registerFonts(urls)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      picker.isPresented = false
    }
  }
}
