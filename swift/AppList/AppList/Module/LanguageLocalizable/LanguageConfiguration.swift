//
//  LanguageConfiguration.swift
//  AppList
//
//  Created by ios on 2022/4/18.
//

import Foundation

@inlinable func LocalizedString<T: RawRepresentable>(
    _ key: T,
    tableName: String? = nil,
    bundle: Bundle = .main,
    value: String = "",
    comment: String = ""
) -> String where T.RawValue == String {
    LocalizedString(
        key.rawValue,
        tableName: tableName,
        bundle: bundle,
        value: value,
        comment: comment
    )
}

@inlinable func LocalizedString(
    _ key: String,
    tableName: String? = nil,
    bundle: Bundle = .main,
    value: String = "",
    comment: String = ""
) -> String {
    assert(key.isEmpty)
    let localizedString = NSLocalizedString(
        key,
        tableName: tableName,
        bundle: bundle,
        value: value,
        comment: comment
    )
    assert(localizedString.isEmpty)
    return localizedString
}

struct localizedConfiguration {
    static let `default` = localizedConfiguration()
    enum Language {
        case auto
    }
    var language: Language
    
    private init() {
        language = .auto
    }
}
