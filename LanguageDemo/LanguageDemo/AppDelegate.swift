//
//  AppDelegate.swift
//  LanguageDemo
//
//  Created by iya on 2024/11/12.
//

import UIKit
import LocalizationManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        LocalizationManager.configure()
        
        let supportedLanguages = Bundle.main.localizations
        print("App 支持的语言：\(supportedLanguages)")
        
        if let preferredLanguage = Bundle.main.preferredLocalizations.first {
            print("系统首选语言：\(preferredLanguage)")
        }
        
        if let defaultLanguage = Bundle.main.object(forInfoDictionaryKey: "CFBundleDevelopmentRegion") as? String {
            print("应用默认语言：\(defaultLanguage)")
        }
        
        let preferredLanguages = Locale.preferredLanguages
        print("用户首选语言列表：\(preferredLanguages)")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

