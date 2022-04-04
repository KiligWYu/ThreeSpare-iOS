//
//  AboutThreeSpare.swift
//  ThreeSpare
//
//  Created by 𝕶𝖎𝖑𝖎𝖌 on 2022/2/25.
//

import SwiftUI

struct AboutThreeSpareView: View {
  var body: some View {
    VStack {
      Text("""
      『冬者岁之余，夜者日之余，阴雨者时之余也。』三余是[每日一文](https://meiriyiwen.com/)的非官方客户端。

      『每日一文是一个简单的中文阅读网站，只为简单的纯净的阅读而生。』

      利用碎片时间，打开三余或每日一文，『每天花 10 分钟阅读一篇文章，一个月可以有大约 50,000 字的阅读量，一年有近 60 万字的阅读量，专注、执着，每天阅读。』

      『简单生活，每日一文。』
      """)
      .multilineTextAlignment(TextAlignment.leading)
      .padding(.top)
      .padding(.horizontal)

      Spacer()
    }
  }
}

struct AboutThreeSpare_Previews: PreviewProvider {
  static var previews: some View {
    AboutThreeSpareView()
  }
}
