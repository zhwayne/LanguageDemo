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
    
    func fetchLocalizationFile(languageCode: String, tableName: String, to destination: URL) async throws {
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let bundleFileURL = Bundle.main.url(forResource: "\(tableName)_\(languageCode)", withExtension: "txt")!
        try fileManager.copyItem(at: bundleFileURL, to: destination)
        
        guard fileManager.fileExists(atPath: destination.path) else {
            throw LocalizationError.fileNotFound
        }
    }
}
