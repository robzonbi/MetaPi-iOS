//
//  GalleryViewModel.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-06-02
//

import SwiftUI
import UniformTypeIdentifiers
import ImageIO
import PhotosUI

class GalleryViewModel: ObservableObject {
    @Published var images: [ImageItem] = []
    @Published var showPhotoPicker: Bool = false
    @Published var selectedPickerItems: [PhotosPickerItem] = []
    @Published var isSelecting: Bool = false
    @Published var selectedImageIDs: Set<String> = []
    @Published var imagesPerRow: Int = 4
    @Published var isLoading: Bool = true
    @ObservedObject var preferences = UserPreferences.shared
    
    @Published var isShowingSortMenu: Bool = false
    
    let maxBatchEditCount = 12

    var selectedImageItems: [ImageItem] {
        images.filter { selectedImageIDs.contains($0.id) }
    }

    var canEditBatchMetadata: Bool {
        selectedImageItems.count >= 1 && selectedImageItems.count <= maxBatchEditCount
    }
    
    
    private func extractTimestamp(from url: URL) -> Int64 {
        let filename = url.deletingPathExtension().lastPathComponent
        let parts = filename.split(separator: "_")
        guard parts.count >= 4, let timestamp = Int64(parts[3]) else {
            return 0
        }
        return timestamp
    }

    
    func sortImages() {
        switch preferences.selectedSortOption {
        case .recentlyAdded:
            images.sort {
                extractTimestamp(from: $0.imageURL) > extractTimestamp(from: $1.imageURL)
            }
        case .dateCaptured:
            images.sort { ($0.metadata.dateTimeOriginal ?? .distantPast) > ($1.metadata.dateTimeOriginal ?? .distantPast) }
        case .modifiedDate:
            images.sort { ($0.metadata.dateTimeDigitized ?? .distantPast) > ($1.metadata.dateTimeDigitized ?? .distantPast) }
        }
    }
    
    
    func saveSelectedImagesToLibrary() async -> (saved: Int, failed: Int) {
        let selectedItems = images.filter { selectedImageIDs.contains($0.id) }
        var savedCount = 0
        var failedCount = 0
        
        for item in selectedItems {
            let result = await saveImageItemToLibrary(item)
            if result.success {
                savedCount += 1
            } else {
                failedCount += 1
                print("Failed to save \(item.imageURL.lastPathComponent): \(result.error ?? "Unknown error")")
            }
        }
        
        return (savedCount, failedCount)
    }
    
    private func saveImageItemToLibrary(_ item: ImageItem) async -> (success: Bool, error: String?) {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            return (false, "Photo Library permission denied")
        }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                let req = PHAssetCreationRequest.forAsset()
                req.addResource(with: .photo, fileURL: item.imageURL, options: nil)
            }
            return (true, nil)
        } catch {
            return (false, error.localizedDescription)
        }
    }

    
    // Sharesheet logic
    
    func urlsForSelectedImages() -> [URL] {
        return images
            .filter { selectedImageIDs.contains($0.id) }
            .map { $0.imageURL }
    }
    
    // Image selection Logic
    
    func toggleSelectingMode() {
        isSelecting.toggle()
        if !isSelecting {
            selectedImageIDs.removeAll()
        }
    }
    
    func toggleSelection(for image: ImageItem) {
        if selectedImageIDs.contains(image.id) {
            selectedImageIDs.remove(image.id)
        } else {
            selectedImageIDs.insert(image.id)
        }
    }
    
    func selectAll() {
        selectedImageIDs = Set(images.map { $0.id })
    }
    
    func deselectAll() {
        selectedImageIDs.removeAll()
    }
    
    var areAllImagesSelected: Bool {
        !images.isEmpty && selectedImageIDs.count == images.count
    }
    
    func toggleSelectAll() {
        if areAllImagesSelected {
            selectedImageIDs.removeAll()
        } else {
            selectAll()
        }
    }
    
    // GalleryActionBar Zoom Logic
    
    var canZoomIn: Bool {
        imagesPerRow > 1
    }
    
    var canZoomOut: Bool {
        imagesPerRow < 4
    }
    
    func zoomIn() {
        if canZoomIn {
            imagesPerRow -= 1
        }
    }
    
    func zoomOut() {
        if canZoomOut {
            imagesPerRow += 1
        }
    }
    
    private let fileManager = FileManager.default
    
    private var imageDirectory: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func loadImages() {
        isLoading = true
        defer { isLoading = false }

        guard let directory = imageDirectory else { return }

        do {
            let files = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )

            let jpgFiles = files.filter { $0.pathExtension.lowercased() == "jpg" }

            images = jpgFiles.map { url in
                let photoMetadata = PhotoMetadata(imageURL: url)
                photoMetadata.loadMetadata()

                return ImageItem(
                    url: url,
                    metadata: photoMetadata)
            }

            sortImages()

        } catch {
            print("Error loading images: \(error)")
        }
    }


    
    func addImage(data: Data, index: Int) {
        guard let directory = imageDirectory else { return }

        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let filename = String(format: "IMG_MetaPi_%02d_%lld.jpg", index, timestamp)
        let destinationURL = directory.appendingPathComponent(filename)

        let srcOpts: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceShouldCacheImmediately: false
        ]
        guard
            let src = CGImageSourceCreateWithData(data as CFData, srcOpts as CFDictionary),
            let uti = CGImageSourceGetType(src) ?? UTType.jpeg.identifier as CFString?
        else {
            print("Failed to read image source")
            return
        }

        guard let dest = CGImageDestinationCreateWithURL(destinationURL as CFURL, uti, 1, nil) else {
            print("Failed to create destination")
            return
        }
        
        let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil)
        CGImageDestinationAddImageFromSource(dest, src, 0, props)

        guard CGImageDestinationFinalize(dest) else {
            print("Failed to write image")
            return
        }

        let photoMetadata = PhotoMetadata(imageURL: destinationURL)
        photoMetadata.loadMetadata()

        let newItem = ImageItem(
            url: destinationURL,
            metadata: photoMetadata)
        
        images.append(newItem)
        sortImages()
        
        print("Saved image with metadata as JPEG")
    }
    
    func handlePickerSelection() async {
        for (index, item) in selectedPickerItems.enumerated() {
            if let data = try? await item.loadTransferable(type: Data.self) {
                await MainActor.run {
                    addImage(data: data, index: index)
                }
            }
        }
        
        await MainActor.run {
            selectedPickerItems = []
        }
    }
    
    func deleteSelectedImages() {
        let imagesToDelete = images.filter { selectedImageIDs.contains($0.id) }
        
        for item in imagesToDelete {
            do {
                try fileManager.removeItem(at: item.imageURL)
                print("Deleted image \(item.imageURL.lastPathComponent)")
            } catch {
                print("Failed to delete image: \(error)")
            }
        }
        
        // Remove deleted items from the list
        images.removeAll { selectedImageIDs.contains($0.id) }
        
        // Clear selection and exit selection mode
        selectedImageIDs.removeAll()
        isSelecting = false
    }
}

extension GalleryViewModel: GalleryActionBarControlling {
    var selectedSortOption: SortOption {
        get { preferences.selectedSortOption }
        set { preferences.selectedSortOption = newValue }
    }
}
