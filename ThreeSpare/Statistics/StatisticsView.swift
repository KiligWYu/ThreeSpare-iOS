//
//  StatisticsView.swift
//  ThreeSpare
//
//  Created by πΆππππ on 2022/1/24.
//

import CoreData
import Foundation
import SwiftUI

// swiftlint:disable:next: type_body_length
struct StatisticsView: View {
  typealias SelfViewModel = StatisticsViewModel
  @ObservedObject var viewModel = StatisticsViewModel()

  var body: some View {
    Form {
      weeklySection()
      tendSection()
      monthlySection()
      tendSection(isMonth: true)
    }
    .padding(.top, -20)
    .navigationTitle("εζ")
    .navigationBarTitleDisplayMode(.large)
    .onAppear {
      viewModel.updateData()
    }
  }

  /// ζ―ζ₯εΉ³ε
  private func daylyAverage(isMonthlyAverage: Bool = false) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("ζ―ζ₯εΉ³ε")
        .font(.subheadline)
      HStack(alignment: .lastTextBaseline, spacing: 8) {
        HStack(alignment: .center, spacing: 8) {
          Image(systemName: "doc.plaintext")
            .font(.title2)
            .foregroundColor(.accentColor)
          Text(isMonthlyAverage ? viewModel.monthDailyString : viewModel.weekDailyString)
            .font(.system(size: 30))
        }
        Text("εε­")
          .font(.subheadline)
      }
    }
  }

  private func weekBar() -> some View {
    VStack(alignment: .center, spacing: 2) {
      ZStack(alignment: .bottom) {
        HStack(alignment: .bottom, spacing: 5) {
          ForEach(0 ... 6, id: \.self) { index in
            VStack {
              Spacer()
                .frame(minHeight: 0)
              Rectangle()
                .fill(
                  LinearGradient(colors: [.accentColor.opacity(0.6), .accentColor],
                                 startPoint: .bottom,
                                 endPoint: .top)
                )
                .frame(width: SelfViewModel.barWidth, height: viewModel.weekBarHeights[index], alignment: .bottom)
                .cornerRadius(SelfViewModel.cornerRadius)
            }
          }
        }
        .frame(height: SelfViewModel.barHeightMax)
        Rectangle()
          .frame(width: (SelfViewModel.barWidth + 5) * 7 + 5, height: 2)
          .foregroundColor(.cyan)
          .offset(y: {
            if viewModel.weekMax == 0 {
              return -SelfViewModel.barHeightMin + 1
            } else {
              return min(-SelfViewModel.barHeightMin + 1,
                         -CGFloat(viewModel.weekDaily) / CGFloat(viewModel.weekMax) * SelfViewModel.barHeightMax
                           - SelfViewModel.barHeightMin + 1)
            }
          }())
      }

      HStack(alignment: .firstTextBaseline, spacing: 5) {
        ForEach(0 ... 6, id: \.self) { index in
          Text(viewModel.daysOfWeek[index])
            .font(.caption)
            .frame(width: SelfViewModel.barWidth)
            .foregroundColor(Color.accentColor)
        }
      }
      .padding(.top, 2)
    }
  }

  private func weeklySection() -> some View {
    Section {
      VStack(alignment: .leading, spacing: 12) {
        Text("ζ¨θΏε» 7 ε€©ηζ―ζ₯εΉ³ειθ―»ιδΈΊ \(viewModel.weekDailyString) εε­γ")
          .multilineTextAlignment(.leading)
        Divider()
        HStack {
          Spacer()
          daylyAverage()
          Spacer()
          weekBar()
        }
      }
      .padding(.top, 10)
    } header: {
      Text("ε¨ζ₯")
        .font(.title2)
        .fontWeight(.medium)
        .foregroundColor(.primary)
        .padding(.leading, -20)
        .padding(.vertical, 4)
    }
  }

  // MARK: -

  private func monthlySection() -> some View {
    Section {
      VStack(alignment: .leading, spacing: 12) {
        Text("ζ¨θΏε» 4 ε¨ηζ―ζ₯εΉ³ειθ―»ιδΈΊ \(viewModel.monthDailyString) εε­γ")
          .multilineTextAlignment(.leading)
        Divider()
        HStack {
          Spacer()
          daylyAverage(isMonthlyAverage: true)
          Spacer()
          monthBarView()
        }
      }
      .padding(.top, 10)
    } header: {
      Text("ζζ₯")
        .font(.title2)
        .fontWeight(.medium)
        .foregroundColor(.primary)
        .padding(.leading, -20)
        .padding(.vertical, 4)
    }
  }

  private func monthBarView() -> some View {
    VStack(alignment: .center, spacing: 2) {
      ZStack(alignment: .bottom) {
        HStack(alignment: .bottom, spacing: 5) {
          ForEach(0 ... 6, id: \.self) { index in
            VStack {
              Spacer()
                .frame(minHeight: 0)
              Rectangle()
                .fill(
                  LinearGradient(colors: [.accentColor.opacity(0.6), .accentColor],
                                 startPoint: .bottom,
                                 endPoint: .top)
                )
                .frame(width: SelfViewModel.barWidth, height: viewModel.monthBarHeights[index])
                .cornerRadius(SelfViewModel.cornerRadius)
            }
            .frame(height: SelfViewModel.monthBarHeightMax)
          }
        }
        Rectangle()
          .frame(width: (SelfViewModel.barWidth + 5) * 7 + 5, height: 2)
          .foregroundColor(.cyan)
          .offset(y: {
            let monthBarReadMax = viewModel.monthBarReadCounts.max() ?? 0
            if monthBarReadMax == 0 {
              return -SelfViewModel.barHeightMin + 1
            } else {
              return min(-SelfViewModel.barHeightMin + 1,
                         -CGFloat(viewModel.monthTotal) / 7 / CGFloat(monthBarReadMax) * SelfViewModel.monthBarHeightMax
                           - SelfViewModel.barHeightMin + 1)
            }
          }())
      }

      HStack(alignment: .bottom, spacing: 5) {
        ForEach(0 ... 6, id: \.self) { index in
          Text(["ζ₯", "δΈ", "δΊ", "δΈ", "ε", "δΊ", "ε­"][index])
            .font(.caption)
            .frame(width: SelfViewModel.barWidth)
            .foregroundColor(Color.accentColor)
        }
      }
      .padding(.top, 2)

      monthIndicatorsView()
    }
  }

  private func monthIndicatorsView() -> some View {
    ForEach(0 ..< viewModel.month.count / 7, id: \.self) { row in
      HStack(alignment: .bottom, spacing: 5) {
        ForEach(0 ... 6, id: \.self) { index in
          HStack {
            Spacer().frame(minWidth: 0)
            Circle()
              .frame(width: SelfViewModel.barWidth / 2)
              .foregroundColor({
                if (viewModel.month[row * 7 + index].keys.first ?? "").isEmpty {
                  return Color.gray.opacity(0.4)
                } else {
                  let count = viewModel.month[row * 7 + index].values.first ?? 0
                  if count < 800 {
                    return Color.accentColor.opacity(0.4)
                  } else if count < 2400 {
                    return Color.accentColor.opacity(0.7)
                  } else {
                    return Color.accentColor
                  }
                }
              }())
            Spacer().frame(minWidth: 0)
          }
          .frame(width: SelfViewModel.barWidth)
        }
      }
      .padding(.top, 2)
    }
  }

  // MARK: -

  private func tendImage(isMonth: Bool) -> some View {
    Image(systemName: isMonth ? viewModel.monthTendImageName : viewModel.weekTendImageName)
      .font(.largeTitle)
      .padding(.top, 10)
  }

  // swiftlint:disable:next function_body_length
  private func tendSection(isMonth: Bool = false) -> some View {
    Section {
      VStack(alignment: .leading, spacing: 12) {
        Text(isMonth ? viewModel.monthTendString : viewModel.weekTendString)
        Divider()
        HStack(alignment: .top, spacing: 10) {
          tendImage(isMonth: isMonth)
          VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .lastTextBaseline) {
              Text("\(isMonth ? viewModel.monthTotalString : viewModel.weekTotalString) εε­")
                .font(.headline)
              Text("δ» \(isMonth ? viewModel.monthStartDateString : viewModel.weekStartDateString)θ³δ»ε€©")
                .font(.caption)
            }
            GeometryReader { reader in
              let maxCount = isMonth ?
                max(viewModel.lastMonthTotal, viewModel.monthTotal) : max(viewModel.lastWeekTotal, viewModel.weekTotal)
              let width =
                maxCount == 0 ? SelfViewModel.barHeightMin :
                reader.size.width * (
                  isMonth ? CGFloat(viewModel.monthTotal) : CGFloat(viewModel.weekTotal)
                ) / CGFloat(maxCount)
              Rectangle()
                .fill(
                  LinearGradient(colors: [.accentColor.opacity(0.6), .accentColor],
                                 startPoint: .leading,
                                 endPoint: .trailing)
                )
                .frame(width: max(SelfViewModel.barHeightMin, width), height: SelfViewModel.barWidth)
                .cornerRadius(SelfViewModel.cornerRadius)
            }

            HStack(alignment: .lastTextBaseline) {
              Text("\(isMonth ? viewModel.lastMonthTotalString : viewModel.lastWeekTotalString) εε­")
                .font(.headline)
              Text(isMonth ? "δΉεδΈδΈͺζ" : "δΉεδΈε¨")
                .font(.caption)
            }
            .padding(.top, 10)
            GeometryReader { reader in
              let maxCount = isMonth ?
                max(viewModel.lastMonthTotal, viewModel.monthTotal) : max(viewModel.lastWeekTotal, viewModel.weekTotal)
              let width =
                maxCount == 0 ? SelfViewModel.barHeightMin :
                reader.size.width * (
                  isMonth ? CGFloat(viewModel.lastMonthTotal) : CGFloat(viewModel.lastWeekTotal)
                ) / CGFloat(maxCount)
              Rectangle()
                .fill(
                  LinearGradient(colors: [.cyan.opacity(0.6), .cyan],
                                 startPoint: .leading,
                                 endPoint: .trailing)
                )
                .frame(width: max(SelfViewModel.barHeightMin, width), height: SelfViewModel.barWidth)
                .cornerRadius(SelfViewModel.cornerRadius)
            }
          }
        }
      }
      .padding(.vertical, 10)
    }
  }
}
