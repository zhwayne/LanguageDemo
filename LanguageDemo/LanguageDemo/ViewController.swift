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
    
    let items = ["en", "zh-Hans", "ja"]

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
        LocalizationManager.shared.currentLanguage = items[sender.selectedSegmentIndex]
        reloadStrings()
    }
    
    @IBAction func onDownloadButtonClick(_ sender: UIButton) {
        sender.isEnabled = false
        Task {
            defer { sender.isEnabled = true }
            do {
                let source = BundleLocalizationSource()
                let downloader = LocalizationDownloader(source: source)
                try await downloader.fetchLocalizationFiles([
                    .init(languageCode: "en", url: URL(fileURLWithPath: "")),
                    .init(languageCode: "zh-Hans", url: URL(fileURLWithPath: "")),
                    .init(languageCode: "ja", url: URL(fileURLWithPath: ""))
                ])
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
    
        let preferredLanguage = LocalizationManager.shared.currentLanguage
        segmentControl.selectedSegmentIndex = items.firstIndex(of: preferredLanguage) ?? 0
    }
}
