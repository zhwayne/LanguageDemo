//
//  LocalizationDownloader.swift
//  LanguageManager
//
//  Created by iya on 2024/11/12.
//

import Foundation

final class LocalizationDownloader<Source: LocalizationSource>: @unchecked Sendable {

    // MARK: - Properties

    let source: Source
    let fileManager: FileManager

    // MARK: - Initialization

    init(source: Source, fileManager: FileManager = .default) {
        self.source = source
        self.fileManager = fileManager
    }

    // MARK: - Public Methods

    /// 下载或加载多个本地化文件
    @discardableResult
    func fetchLocalizationFiles(_ localizationFiles: [LocalizationFile]) async throws -> [URL] {
        var fetchedURLs: [URL] = []

        let basePath = LocalizationManager.shared.basePath
        
        try await withThrowingTaskGroup(of: URL.self) { group in
            for file in localizationFiles {
                group.addTask {
                    let lproj = basePath.appendingPathComponent("\(file.languageCode).lproj")
                    if !self.fileManager.fileExists(atPath: lproj.path) {
                        try self.fileManager.createDirectory(at: lproj, withIntermediateDirectories: true)
                    }
                    let destination = lproj.appendingPathComponent("\(file.tableName).strings")
                    try await self.source.fetchLocalizationFile(
                        languageCode: file.languageCode,
                        tableName: file.tableName,
                        from: file.url,
                        to: destination
                    )
                    return destination
                }
            }

            for try await url in group {
                fetchedURLs.append(url)
            }
        }

        return fetchedURLs
    }
}
