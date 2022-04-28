//
//  NetworkSession.swift
//  AppList
//
//  Created by ios on 2022/4/18.
//

import Foundation
import Combine

protocol RequestConverter {
    func asRequest() throws -> URLRequest
}

class NetworkSession {
    func request<T>(
        _ converter: RequestConverter,
        parser: @escaping ((Data, URLResponse)) throws -> T
    ) throws -> AnyPublisher<T, Error> {
        try URLSession.shared
            .dataTaskPublisher(for: converter.asRequest())
            .tryMap({ try parser($0) })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func request<T: Decodable>(
        _ converter: RequestConverter,
        dataType: T.Type
    ) throws -> AnyPublisher<T, Error> {
        try request(converter) {
            try JSONDecoder().decode(T.self, from: $0.0)
        }
    }
}
