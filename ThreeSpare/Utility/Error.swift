//
//  Error.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/1/15.
//

import Foundation

enum ThreeSpareError: Error {
  enum Request: Error {
    case network
    case emptyResponse
    case decodeFail
  }

  enum StorageError: Error {
    case saveFail
  }

  enum AppError: Error {
  }
}

extension ThreeSpareError.AppError {
  enum Reading {
    case generatePDFFail
  }

  enum RegisterFontError {
    case common
    case fontExist
    case createDirectoryFail
    case copyFontFileFail
  }
}

extension ThreeSpareError.Request: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .network, .emptyResponse:
      return "网络错误，请稍后再试"
    case .decodeFail:
      return "数据解析错误"
    }
  }
}

extension ThreeSpareError.AppError.Reading: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .generatePDFFail:
      return "生成 PDF 失败"
//    case .registerFontError:
//      return "导入字体失败"
    }
  }
}

extension ThreeSpareError.AppError.RegisterFontError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .common:
      return "导入字体失败"
    case .fontExist:
      return "字体已存在"
    case .createDirectoryFail:
      return "创建字体文件夹失败"
    case .copyFontFileFail:
      return "复制字体失败Z"
    }
  }
}
