//
//  ViewController.swift
//  LanguageDemo
//
//  Created by iya on 2024/11/12.
//

import UIKit
import SnapKit
import LocalizationManager

class ViewController: UIViewController {
    
    let items: [AppLanguage] = [.custom("en"), .custom("zh-Hans"), .custom("ja"), .system]

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var loadPatchButton: UIButton!
    @IBOutlet weak var cleanButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        reloadStrings()
    }
    
    @IBAction func onSegmentControlValueChanged(_ sender: UISegmentedControl) {
        LocalizationManager.shared.appLanguage = items[sender.selectedSegmentIndex]
        reloadStrings()
    }
    
    private let files = [
        LocalizationFile(
            languageCode: "en",
            tableName: "Localizable",
            url: Bundle.main.url(forResource: "Localizable_en", withExtension: "txt")!
        ),
        LocalizationFile(
            languageCode: "zh-Hans",
            tableName: "Localizable",
            url: Bundle.main.url(forResource: "Localizable_zh-Hans", withExtension: "txt")!
        ),
        LocalizationFile(
            languageCode: "ja",
            tableName: "Localizable",
            url: Bundle.main.url(forResource: "Localizable_ja", withExtension: "txt")!
        )
    ]
    
    @IBAction func onDownloadButtonClick(_ sender: UIButton) {
        sender.isEnabled = false
        Task {
            defer { sender.isEnabled = true }
            do {
                let manager = LocalizationManager.shared
                let source = BundleLocalizationSource()
                try await manager.fetchLocalizationFiles(files, using: source)
                reloadStrings()
            } catch {
                print("error: \(error)")
            }
        }
    }
    
    @IBAction func onCleanButtonClick(_ sender: UIButton) {
        LocalizationManager.shared.cleanPatch()
        reloadStrings()
    }
}

extension ViewController {
    
    private func reloadStrings() {
        loadPatchButton.setTitle(NSLocalizedString("load_patch", comment: "Load patch file"), for: .normal)
        cleanButton.setTitle(NSLocalizedString("clean", comment: "clean patch file"), for: .normal)
        
        label.text = NSLocalizedString("hello_world", comment: "hello world")
    
        let appLanguage = LocalizationManager.shared.appLanguage
        segmentControl.selectedSegmentIndex = items.firstIndex(of: appLanguage) ?? 0
    }
}
