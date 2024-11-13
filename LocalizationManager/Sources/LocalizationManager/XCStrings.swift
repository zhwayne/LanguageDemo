//
//  XCStrings.swift
//  LanguageManager
//
//  Created by iya on 2024/11/12.
//

import Foundation

// 定义错误类型
enum XCStringsError: Error {
    case fileNotFound
    case invalidFormat
    case parseError
}

// 定义键值对结构
struct XCStringEntry {
    let key: String
    let value: String
}

// 定义本地化字符串管理类
class XCStrings {
    private var entries: [String: String] = [:]
    
    init(entries: [XCStringEntry]) {
        for entry in entries {
            self.entries[entry.key] = entry.value
        }
    }
    
    func localizedString(forKey key: String) -> String? {
        return entries[key]
    }
}

// 解析器类
class XCStringsParser {
    static func parse(from url: URL) throws -> XCStrings {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw XCStringsError.fileNotFound
        }
        
        let content = try String(contentsOf: url, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)
        var entries: [XCStringEntry] = []
        
        let pattern = "\"(.*?)\"\\s*=\\s*\"(.*?)\";"
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("//") {
                continue // 跳过空行和注释
            }
            
            let range = NSRange(location: 0, length: trimmedLine.utf16.count)
            if let match = regex.firstMatch(in: trimmedLine, options: [], range: range) {
                if match.numberOfRanges == 3,
                   let keyRange = Range(match.range(at: 1), in: trimmedLine),
                   let valueRange = Range(match.range(at: 2), in: trimmedLine) {
                    let key = String(trimmedLine[keyRange])
                    let value = String(trimmedLine[valueRange])
                    entries.append(XCStringEntry(key: key, value: value))
                } else {
                    throw XCStringsError.invalidFormat
                }
            } else {
                throw XCStringsError.parseError
            }
        }
        
        return XCStrings(entries: entries)
    }
}

// 本地化管理类
class XCStringsBundle: @unchecked Sendable {
    // 单例实例，类似于 Bundle.main
    static let main = XCStringsBundle()
    
    // 存储已加载的本地化表
    private var localizedTables: [String: XCStrings] = [:]
    
    // 基础路径，默认为空，用户可自定义
    private var basePath: String?
    
    // 私有初始化，防止外部直接实例化
    private init() {}
    
    // 公开初始化，允许指定基础路径
    init(basePath: String) {
        self.basePath = basePath
    }
    
    /// 设置基础路径
    func setBasePath(_ path: String) {
        self.basePath = path
    }
    
    /// 加载指定表和语言的 .xcstrings 文件
    func load(table: String, language: String) throws {
        guard let basePath = self.basePath else {
            throw XCStringsError.fileNotFound
        }
        
        // 构建 .xcstrings 文件路径
        let languagePath = "\(basePath)/\(language).lproj/\(table).strings"
        let fileURL = URL(fileURLWithPath: languagePath)
        let strings = try XCStringsParser.parse(from: fileURL)
        localizedTables[table] = strings
    }
    
    /// 获取本地化字符串
    func localizedString(forKey key: String, table tableName: String) -> String? {
        let currentLanguage = LocalizationManager.shared.currentLanguage
        
        // 如果指定表未加载，则尝试加载
        if localizedTables[tableName] == nil {
            do {
                try load(table: tableName, language: currentLanguage)
            } catch {
                // 加载失败，返回默认值
                return nil
            }
        }
        
        return localizedTables[tableName]?.localizedString(forKey: key)
    }
    
    func clean() {
        localizedTables = [:]
    }
}

extension XCStringsBundle {
    /// 刷新指定的本地化表
    func refresh(table: String, language: String? = nil) throws {
        let lang = language ?? LocalizationManager.shared.currentLanguage
        try load(table: table, language: lang)
    }
    
    /// 设置新的基础路径并清空缓存
    func updateBasePath(_ path: String) throws {
        self.basePath = path
        self.localizedTables.removeAll()
    }
}
