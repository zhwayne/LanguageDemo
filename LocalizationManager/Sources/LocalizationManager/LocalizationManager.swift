// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

private var appDefaultLanguageCode: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleDevelopmentRegion") as? String ?? "en"
}

private var systemPreferredLanguageCode: String {
    Bundle.main.preferredLocalizations.first ?? appDefaultLanguageCode
}

public enum AppLanguage: Hashable, Sendable {
    case system
    case custom(String)
    
    var languageCode: String {
        switch self {
        case .system: return systemPreferredLanguageCode
        case .custom(let code): return code
        }
    }
}

public class LocalizationManager: @unchecked Sendable {
    
    // MARK: - Singleton
    
    public static let shared = LocalizationManager()
    
    // MARK: - Properties
    
    private let storage = UserDefaults.standard
    private let userDefaultsKey = "AppLanguage"
    
    public var tableNames: Set<String> = ["Localizable"]
    
    public var appLanguage: AppLanguage {
        get {
            if let languageCode = storage.string(forKey: userDefaultsKey), languageCode != "system" {
                return .custom(languageCode)
            }
            return .system
        }
        set {
            switch newValue {
            case .system: storage.set("system", forKey: userDefaultsKey)
            case .custom(let code): storage.set(code, forKey: userDefaultsKey)
            }
            storage.synchronize()
            
            // 更新 Bundle.main 的关联语言包
            updateBundlePath(for: newValue)
        }
    }
        
    public static func configure() {
        let _ = LocalizationManager.shared
    }
    
    private init() {
        CustomBundle.once
        XCStringsBundle.main.setBasePath(basePath.path)
        appLanguage = appLanguage
    }
    
    // MARK: - Methods
    
    /// 更新 Bundle.main 的语言包路径
    private func updateBundlePath(for language: AppLanguage) {
        switch language {
        case .system:
            objc_setAssociatedObject(Bundle.main, &bundleKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        case .custom(let languageCode):
            if let bundlePath = Bundle.main.path(forResource: languageCode, ofType: "lproj") {
                let languageBundle = Bundle(path: bundlePath)
                objc_setAssociatedObject(Bundle.main, &bundleKey, languageBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        // FIXME: 需要重新加载该语言下的所有 table，这里只先列出 Localizable（和主工程保持一致）
        tableNames.forEach { table in
            try? XCStringsBundle.main.load(table: table, language: language.languageCode)
        }
    }
}

extension LocalizationManager {
    
    var basePath: URL {
        let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("Localization")
    }
    
    public func cleanAllPatchFiles() {
        let fileManager = FileManager.default
        let basePath = LocalizationManager.shared.basePath
        
        guard fileManager.fileExists(atPath: basePath.path) else {
            XCStringsBundle.main.clean()
            return
        }
        
        do {
            try fileManager.removeItem(at: basePath)
            XCStringsBundle.main.clean()
        } catch {
            print("删除资源文件失败: \(error)")
        }
    }
}

extension LocalizationManager {
    
    public func fetchPatchFiles(_ localizationFiles: [LocalizationFile], using localizationSource: some LocalizationSource) async throws {
        let downloader = LocalizationDownloader(source: localizationSource)
        try await downloader.fetchLocalizationFiles(localizationFiles)
        
        // 加载当前语言和表的 .xcstring 文件
        for file in localizationFiles where file.languageCode == appLanguage.languageCode {
            if !tableNames.contains(file.tableName) {
                tableNames.insert(file.tableName)
            }
            try XCStringsBundle.main.load(table: file.tableName, language: file.languageCode)
        }
    }
}
