//
//  NetworkLocalizationSource.swift
//  LanguageManager
//
//  Created by iya on 2024/11/12.
//

import Foundation
import LocalizationManager

class NetworkLocalizationSource: LocalizationSource {
    
    private let session: URLSession
    private let fileManager: FileManager
    
    init(session: URLSession = .shared, fileManager: FileManager = .default) {
        self.session = session
        self.fileManager = fileManager
    }
    
    func fetchLocalizationFile(languageCode: String, tableName: String, from source: URL, to destination: URL) async throws {
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        
        // 下载文件
        do {
            let (tempURL, _) = try await session.download(from: source)
            // 移动文件到目标路径
            try fileManager.moveItem(at: tempURL, to: destination)
        } catch {
            throw LocalizationError.downloadFailed(error)
        }
    }
}
