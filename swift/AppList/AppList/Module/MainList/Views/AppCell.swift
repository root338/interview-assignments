//
//  AppCell.swift
//  AppList
//
//  Created by ios on 2022/4/18.
//

import SwiftUI

struct AppCell: View {
    typealias LikedActionTuple = (
        isLiked: Bool,
        completion: (_ isSuccess: Bool) -> Void
    )
    @State var item: AppInfo
    var likedAction: ((LikedActionTuple) -> Void)
    
    var body: some View {
        HStack(alignment: .center) {
            
            AsyncImage(url: URL(string: item.artworkUrl)) {
                $0.resizable(
                    capInsets: EdgeInsets(),
                    resizingMode: .stretch
                ).cornerRadius(5)
            } placeholder: {
                ActivityIndicator(style: .medium, isAnimating: true)
            }
            .frame(width: 45, height: 45)
            .padding([.leading], 10)
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.system(size: 15, weight: .medium, design: .default))
                Text(item.description)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .lineLimit(2)
            }
            .padding([.leading, .trailing], 10)
            Spacer()
            Button {
                let newLikedValue = !item.isLiked
                likedAction((newLikedValue, {
                    if !$0 { return }
                    self.item.isLiked = newLikedValue
                }))
            } label: {
                let isLiked = item.isLiked
                Image(systemName: isLiked ? "heart.fill" : "heart")
                .symbolRenderingMode(.monochrome)
                .foregroundColor(isLiked ? .red : .gray)
                .scaleEffect(item.isLiked ? 1 : 0.8)
                .animation(.linear(duration: 0.2), value: item.isLiked)
            }
            .padding([.trailing], 10)
        }
    }
}
