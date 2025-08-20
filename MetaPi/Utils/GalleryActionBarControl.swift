//
//  GalleryActionBarControl.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-30.
//

import SwiftUI

protocol GalleryActionBarControlling: ObservableObject {
    var isSelecting: Bool { get set }
    var imagesPerRow: Int { get set }

    var canZoomIn: Bool { get }
    var canZoomOut: Bool { get }

    func toggleSelectingMode()
    func selectAll()
    func zoomIn()
    func zoomOut()
    var areAllImagesSelected: Bool { get }
    func toggleSelectAll()
    var selectedSortOption: SortOption { get set }
    var isShowingSortMenu: Bool { get set }
}
