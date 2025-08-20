//
//  UserPreferences.swift
//  MetaPi
//
//  Created by Yuhang Zhou on 2025-07-17.
//

import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case light, dark, system
    var id: String { rawValue }
}

enum DefaultMetadataTag: String, CaseIterable, Identifiable {
    case allTags, exif, iptc, pi3d
    var id: String { rawValue }
}


class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    private let defaults = UserDefaults.standard
    

    private enum Keys {
        static let theme = "appTheme"
        static let tags = "metadataTags"
        static let selectedSortOption = "selectedSortOption"
    }

    @Published var theme: AppTheme {
        didSet {
            defaults.set(theme.rawValue, forKey: Keys.theme)
        }
    }
    
    var preferredScheme: ColorScheme? {
        switch theme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    @Published var tags: DefaultMetadataTag {
        didSet {
            defaults.set(tags.rawValue, forKey: Keys.tags)
        }
    }

    @Published var selectedSortOption: SortOption {
        didSet {
            defaults.set(selectedSortOption.rawValue, forKey: Keys.selectedSortOption)
        }
    }
    
    private init() {
        // Theme
        let rawTheme = defaults.string(forKey: Keys.theme) ?? AppTheme.system.rawValue
        self.theme = AppTheme(rawValue: rawTheme) ?? .system
        
        // Metadata tags
        let rawTags = defaults.string(forKey: Keys.tags) ?? DefaultMetadataTag.allTags.rawValue
        self.tags = DefaultMetadataTag(rawValue: rawTags) ?? .allTags

        // Sort Option
        let rawSort = defaults.string(forKey: Keys.selectedSortOption) ?? SortOption.recentlyAdded.rawValue
        self.selectedSortOption = SortOption(rawValue: rawSort) ?? .recentlyAdded
    }
}

