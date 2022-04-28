//
//  MainListView.swift
//  AppList
//
//  Created by ios on 2022/4/18.
//

import SwiftUI

struct MainListView: View {
    @ObservedObject var dataService = AppListDataService(params: .init(
        entity: "software",
        limit: 50,
        term: "chat"
    ))
    
    var body: some View {
        NavigationView {
            ZStack {
                if dataService.list.isEmpty {
                    ActivityIndicator(style: .medium, isAnimating: true)
                        .onAppear {
                            dataService.reset()
                        }
                }else {
                    List {
                        ForEach(dataService.list) { item in
                            AppCell(item: item) { likedActionValue in
                                Task {
                                    likedActionValue.completion(
                                        (try? await dataService.update(
                                            isLiked: likedActionValue.isLiked,
                                            at: item.id
                                        )) != nil ? true : false
                                    )
                                }
                            }
                            .frame(height: 70)
                            .listRowSeparator(.hidden)
                            .listRowBackground(backgroundColor())
                            .background(.white)
                            .cornerRadius(10)
                        }
                        TextActivityRefresh(
                            state: {
                                switch dataService.loadingState {
                                case .idle: return .idle
                                case .didFinish: return .noMoreData
                                case .loading: return .refreshing
                                }
                            }()
                        )
                            .listRowBackground(backgroundColor())
                            .onAppear {
                                if dataService.loadingState != .idle { return }
                                dataService.next()
                            }
                    }
                    .listStyle(PlainListStyle())
                    .background(backgroundColor())
                    .refreshable {
                        dataService.reset()
                    }
                }
            }
            .navigationTitle("App")
        }
    }
    
    private func backgroundColor() -> Color {
        Color(white: 0.95)
    }
}

struct MainListView_Previews: PreviewProvider {
    static var previews: some View {
        MainListView()
    }
}
