//
//  ActivityIndicator.swift
//  AppList
//
//  Created by ios on 2022/4/18.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    typealias UIViewType = UIActivityIndicatorView
    @State var style = UIActivityIndicatorView.Style.medium
    @State var isAnimating = false
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: style)
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.style = style
        if isAnimating != uiView.isAnimating {
            isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        }
    }
}
