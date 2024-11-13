// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@available(iOS 13.0, *)
public class LocalizationManager: @unchecked Sendable {
    
    // MARK: - Singleton
    
    public static let shared = LocalizationManager()
    
    // MARK: - Properties
    
    private let storage = UserDefaults.standard
    private let userDefaultsKey = "AppLanguage"
    
    public var defaultLanguage: String = Locale.preferredLanguages.first ?? "en"
    
    public var currentLanguage: String {
        get {
            return storage.string(forKey: userDefaultsKey) ?? defaultLanguage
        }
        set {
            storage.set(newValue, forKey: userDefaultsKey)
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
        currentLanguage = currentLanguage
    }
    
    // MARK: - Methods
    
    /// 更新 Bundle.main 的语言包路径
    private func updateBundlePath(for languageCode: String) {
        var bundlePath = Bundle.main.path(forResource: languageCode, ofType: "lproj")
        if bundlePath == nil {
            // 如果找不到对应的语言包，使用英文
            bundlePath = Bundle.main.path(forResource: defaultLanguage, ofType: "lproj")
        }
        if bundlePath == nil {
            return
        }
        let languageBundle = Bundle(path: bundlePath!)
        objc_setAssociatedObject(Bundle.main, &bundleKey, languageBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        // FIXME: 需要重新加载该语言下的所有 table，这里只先列出 Localizable（和主工程保持一致）
        try? XCStringsBundle.main.load(table: "Localizable", language: languageCode)
    }
}

extension LocalizationManager {
    
    var basePath: URL {
        let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("Localization")
    }
    
    public func cleanPatch() {
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
