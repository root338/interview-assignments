//
//  ListRefresh.swift
//  AppList
//
//  Created by ios on 2022/4/18.
//

import SwiftUI

enum ListRefreshState {
    case idle
    case pulling
    case refreshing
    case willRefresh
    case noMoreData
}

struct TextActivityRefresh: View {
    @State var spacing: CGFloat?
    @State var state: ListRefreshState
    @State var texts: [ListRefreshState: String] = [
        .idle : "loading",
        .pulling : "loading",
        .refreshing : "loading",
        .willRefresh : "loading",
        .noMoreData : "No more data."
    ]
    var body: some View {
        HStack(alignment: .center, spacing: self.spacing) {
            Spacer()
            if state != .noMoreData {
                ActivityIndicator(style: .medium, isAnimating: true)
            }
            Text(texts[state] ?? "")
                .font(.system(size: 13, weight: .regular, design: .default))
            Spacer()
        }
    }
}
