//
//  StatisticsViewModel.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/4/2.
//

import Foundation
import SwiftUI
import Combine

class StatisticsViewModel: ObservableObject {
  private enum ReadingTend {
    case increase
    case flat
    case decrease
  }

  static let barHeightMax: CGFloat = 80
  static let monthBarHeightMax: CGFloat = 80
  static let barHeightMin: CGFloat = 6
  static let barWidth: CGFloat = 15
  static let cornerRadius: CGFloat = 3

  @Published var daysOfWeek = [String]()

  @Published var weekDaily: Float = 0
  @Published var weekTotal = 0 {
    didSet {
      weekTotalString = String(format: "%.1f", Float(weekTotal) / 1000)
        .replacingOccurrences(of: ".0", with: "")
    }
  }
  @Published var weekMax = 0
  @Published var weekDailyString = ""
  @Published var weekTotalString = ""
  @Published var weekStartDateString = ""
  @Published var weekTendString = ""
  @Published var weekTendImageName = ""
  @Published var lastWeekTotalString = ""
  @Published var lastWeekTotal = 0 {
    didSet {
      lastWeekTotalString = String(format: "%.1f", Float(lastWeekTotal) / 1000)
        .replacingOccurrences(of: ".0", with: "")
    }
  }
  @Published var weekBarHeights = [CGFloat](repeating: 7, count: 0)

  @Published var monthTendString = ""
  @Published var monthTendImageName = ""
  @Published var monthDailyString = ""
  @Published var monthTotalString = ""
  @Published var monthStartDateString = ""
  @Published var lastMonthTotalString = ""
  @Published var monthBarReadCounts = [Int](repeating: 7, count: 0)
  @Published var monthBarHeights = [CGFloat](repeating: 7, count: 0)

  private var group = DispatchGroup()
  private var cancellables = Set<AnyCancellable>()

  // MARK: - week data

  private var week = [Int](repeating: 7, count: 0) {
    didSet {
      weekTotal = week.reduce(0, +)
      weekMax = week.max() ?? 0
      weekDaily = Float(weekTotal) / 7
      weekDailyString = String(format: "%.1f", weekDaily / 1000)
        .replacingOccurrences(of: ".0", with: "")
    }
  }

  private var weekTend: ReadingTend! {
    didSet {
      switch weekTend {
      case .increase:
        weekTendString = "您最近 7 天的阅读量比之前一周更多。"
        weekTendImageName = "arrow.up.right.circle.fill"
      case .flat:
        weekTendString = "您最近 7 天的阅读量与之前一周持平。"
        weekTendImageName = "arrow.right.circle.fill"
      case .decrease:
        weekTendString = "您最近 7 天的阅读量比之前一周更少。"
        weekTendImageName = "arrow.down.right.circle.fill"
      case .none:
        break
      }
    }
  }

// MARK: - month data

  @Published var month = [[String: Int]](repeating: ["": 0], count: 28) {
    didSet {
      let dayOfWeek = Date().dayOfWeek()
      let endIndex = month.count - 1 - (7 - dayOfWeek)
      week = month[endIndex - 6 ... endIndex].compactMap {
        $0.values.first
      }

      lastWeekTotal = month[endIndex - 7 - 6 ... endIndex - 7].compactMap {
        $0.values.first
      }
      .reduce(0, +)

      monthTotal = month.compactMap {
        $0.values.first
      }
      .reduce(0, +)

      calculateWeekBarHeights()
      updateWeekTend()

      calculateMonthBarData()
      calculateMonthBarHeights()
    }
  }

  @Published var monthTotal = 0 {
    didSet {
      monthTotalString = String(format: "%.1f", Float(monthTotal) / 1000)
        .replacingOccurrences(of: ".0", with: "")
      monthDaily = Float(monthTotal) / 28
    }
  }

  private var monthDaily: Float! {
    didSet {
      monthDailyString = String(format: "%.1f", monthDaily / 1000)
        .replacingOccurrences(of: ".0", with: "")
    }
  }

  @Published var lastMonthTotal: Int = 0 {
    didSet {
      lastMonthTotalString = String(format: "%.1f", Float(lastMonthTotal) / 1000)
        .replacingOccurrences(of: ".0", with: "")
    }
  }

  private var monthTend: ReadingTend! {
    didSet {
      switch monthTend {
      case .increase:
        monthTendString = "您最近 4 周的阅读量比之前一个月更多。"
        monthTendImageName = "arrow.up.right.circle.fill"
      case .flat:
        monthTendString = "您最近 4 周的阅读量与之前一个月持平。"
        monthTendImageName = "arrow.right.circle.fill"
      case .decrease:
        monthTendString = "您最近 4 周的阅读量比之前一个月更少。"
        monthTendImageName = "arrow.down.right.circle.fill"
      case .none:
        break
      }
    }
  }

  // MARK: -

  init() {
    DataProvider.shared.monthData.sink { data in
      self.month = data
      self.group.leave()
    }
    .store(in: &cancellables)

    DataProvider.shared.lastMonthReadAmount.sink { amount in
      self.lastMonthTotal = amount
      self.group.leave()
    }
    .store(in: &cancellables)
  }

  func updateData() {
    let daysOfWeek = ["日", "一", "二", "三", "四", "五", "六"]
    let dayOfWeek = Date().dayOfWeek()
    self.daysOfWeek = Array(daysOfWeek[dayOfWeek...] + daysOfWeek[..<dayOfWeek])

    weekStartDateString = DateFormatter.formate("M 月 d 日")
      .string(from: Date().advanced(by: -6 * 24 * 60 * 60))
    monthStartDateString = DateFormatter.formate("M 月 d 日")
      .string(from: Date().advanced(by: -27 * 24 * 60 * 60))

    group.enter()
    group.enter()

    DataProvider.shared.fetchCurrentMonthData()
    DataProvider.shared.fetchLastMonthData()

    group.notify(queue: .main) { [weak self] in
      guard let `self` = self else { return }
      self.updateMonthTend()
     }
  }

  private func calculateWeekBarHeights() {
    guard weekMax > 0 else {
      weekBarHeights = [CGFloat](repeating: Self.barHeightMin, count: 7)
      return
    }
    var heights: [CGFloat] = []
    for words in week {
      heights.append(Self.barHeightMin + CGFloat(words) / CGFloat(weekMax) * (Self.barHeightMax - Self.barHeightMin))
    }
    weekBarHeights = heights
  }

  private func updateWeekTend() {
    let diff = Float(weekTotal - lastWeekTotal)
    if fabsf(diff) < 100 {
      weekTend = .flat
    } else if diff > 0 {
      weekTend = .increase
    } else {
      weekTend = .decrease
    }
  }

  private func updateMonthTend() {
    let diff = Float(monthTotal - lastMonthTotal)
    if fabsf(diff) < 500 {
      monthTend = .flat
    } else if diff > 0 {
      monthTend = .increase
    } else {
      monthTend = .decrease
    }
  }

  private func calculateMonthBarData() {
    var counts = [Int]()
    for index in 0 ..< 7 {
      var monthIndex = index
      var section = [[String: Int]]()
      while monthIndex <= month.count - 1 {
        section.append(month[monthIndex])
        monthIndex += 7
      }
      let count = section.compactMap {
        $0.values.first
      }
        .reduce(0, +)
      counts.append(count)
    }
    monthBarReadCounts = counts
  }

  private func calculateMonthBarHeights() {
    let maxCount = monthBarReadCounts.max() ?? 0
    if maxCount == 0 {
      monthBarHeights = [CGFloat](repeating: Self.barHeightMin, count: 7)
      return
    }
    monthBarHeights = monthBarReadCounts.map {
      Self.barHeightMin + CGFloat($0) / CGFloat(maxCount) * (Self.monthBarHeightMax - Self.barHeightMin)
    }
  }
}
