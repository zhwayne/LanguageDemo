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
    /// - Returns: 本地化文件的 URL
    func fetchLocalizationFile(languageCode: String, tableName: String, to destination: URL) async throws
}


public struct LocalizationFile: Sendable {
    public let languageCode: String      // 例如 "en", "zh-Hans"
    public let tableName: String         // 例如 "Localizable", "Errors"
    public let url: URL                  // 文件的下载/加载地址
    
    public init(languageCode: String, tableName: String = "Localizable", url: URL) {
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
