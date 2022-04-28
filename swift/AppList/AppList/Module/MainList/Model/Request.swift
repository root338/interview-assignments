//
//  Request.swift
//  AppList
//
//  Created by ios on 2022/4/18.
//

import Foundation
// 发送请求对象
// 这里做了简化处理，包括参数只能 [string: String]，不能设置请求类型等等
// 为了 asRequest() 方法可以最简化处理
struct Request: RequestConverter {
    
    enum Error: Swift.Error {
        case isEmpty
    }
    
    let url: URL
    let params: [String: String]
    
    func asRequest() throws -> URLRequest {
        guard var components = URLComponents(
            url: url, resolvingAgainstBaseURL: true
        ) else { throw Error.isEmpty }
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(.init(name: key, value: value))
        }
        components.queryItems = queryItems
        guard let url = components.url else { throw Error.isEmpty }
        return URLRequest(url: url)
    }
}
