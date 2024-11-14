//
//  LocalizationSource.swift
//  LanguageManager
//
//  Created by iya on 2024/11/12.
//

import Foundation

public protocol LocalizationSource {
    
    /// 下载或加载指定语言和表的本地化文件
    /// - Parameters:
    ///   - languageCode: 语言代码，例如 "en", "zh-Hans"
    ///   - tableName: 本地化表名，例如 "Localizable", "Errors"
    ///   - source: 本地化文件源地址
    ///   - destination: 本地化文件目标地址，目前是 /Library/Cache/Localization/your_lang.lproj/table_name.strings
    func fetchLocalizationFile(languageCode: String, tableName: String, from source: URL, to destination: URL) async throws
}


public struct LocalizationFile: Sendable {
    public let languageCode: String      // 例如 "en", "zh-Hans"
    public let tableName: String         // 例如 "Localizable", "Errors"
    public let url: URL                  // 文件的下载/加载地址
    
    public init(languageCode: String, tableName: String, url: URL) {
        self.languageCode = languageCode
        self.tableName = tableName
        self.url = url
    }
}

public enum LocalizationError: Error {
    case invalidURL
    case downloadFailed(Error)
    case fileWriteFailed(Error)
    case fileNotFound
    case invalidFormat
    case parseError
}
