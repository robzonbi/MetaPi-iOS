//
//  SortOption.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-07-12.
//

import Foundation

// GalleryActionBar sorting logic

enum SortOption: String, CaseIterable, Identifiable {
    
    case recentlyAdded = "Sort by Recently Added"
    case modifiedDate = "Sort by Modified Date"
    case dateCaptured = "Sort by Date Captured"
    
    var id: String { rawValue }
}
