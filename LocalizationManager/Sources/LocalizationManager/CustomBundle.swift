//
//  CustomBundle.swift
//  LanguageManager
//
//  Created by iya on 2024/11/12.
//

import Foundation

nonisolated(unsafe) var bundleKey: UInt8 = 0

class CustomBundle: Bundle, @unchecked Sendable {
    
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        
        if let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle {
            if let string = XCStringsBundle.main.localizedString(forKey: key, table: tableName ?? "Localizable") {
                return string
            } else {
                return bundle.localizedString(forKey: key, value: value, table: tableName)
            }
        } else if let string = XCStringsBundle.main.localizedString(forKey: key, table: tableName ?? "Localizable") {
            return string
        } else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}

extension Bundle {
    
    static let once: Void = {
        object_setClass(Bundle.main, CustomBundle.self)
    }()
}
