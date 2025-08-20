//
//  SettingsViewModel.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-22.
//

import Foundation
import SwiftUICore

class SettingsViewModel: ObservableObject {
    @Published var isDarkModeOn = false
    @Published var isMissingLocationOn: Bool {
        didSet {
            UserDefaults.standard.set(isMissingLocationOn, forKey: "MissingLocationIndicatorEnabled")
        }
    }
    @Published var storageUsage: String = "0.00MB"
    @Published var selectedInfo: String? = nil
    
    init() {
        self.isMissingLocationOn = UserDefaults.standard.bool(forKey: "MissingLocationIndicatorEnabled")
    }
    
    func displayStorage() -> String {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "0MB"
        }
        var totalBytes: Int64 = 0
        if let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey]) {
            for case let url as URL in enumerator {
                if let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey]),
                   values.isDirectory != true,
                   let size = values.fileSize {
                    totalBytes += Int64(size)
                }
            }
        }
        let mb = Double(totalBytes) / 1_048_576
        return String(format: "%.1fMB", mb) // rounded to one decimal point
    }
    
    func toggleDarkMode() {
        isDarkModeOn.toggle()
        print("Dark Mode toggled: \(isDarkModeOn)")
    }
    
    func onTap(_ item: String) {
        print("Tapped on: \(item)")
        selectedInfo = item
    }
    
    func toggleMissingLocation() {
        print("missing location is now: \(isMissingLocationOn)")
    }
}
