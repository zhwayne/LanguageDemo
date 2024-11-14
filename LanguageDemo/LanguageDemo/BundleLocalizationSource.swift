//
//  BundleLocalizationSource.swift
//  LanguageDemo
//
//  Created by iya on 2024/11/13.
//

import Foundation
import LocalizationManager

class BundleLocalizationSource: LocalizationSource {
    
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func fetchLocalizationFile(languageCode: String, tableName: String, from source: URL, to destination: URL) async throws {
        guard source.isFileURL else {
            fatalError("source must be file url.")
        }
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        try fileManager.copyItem(at: source, to: destination)
        
        guard fileManager.fileExists(atPath: destination.path) else {
            throw LocalizationError.fileNotFound
        }
    }
}
