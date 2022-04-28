//
//  BaseModel.swift
//  AppList
//
//  Created by ios on 2022/4/18.
//

import Foundation

struct BaseModel<ResultType: Codable>: Codable {
    let resultCount: Int
    let results: ResultType
}
