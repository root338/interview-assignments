//
//  AppInfo.swift
//  AppList
//
//  Created by ios on 2022/4/18.
//

import Foundation

struct AppInfo: Codable, Identifiable {
    let id: Int
    let title: String
    let artworkUrl: String
    let description: String
    var isLiked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case title = "trackName"
        case artworkUrl = "artworkUrl100"
        case description
    }
}
