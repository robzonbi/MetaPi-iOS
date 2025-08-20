//
//  PhotoDetailsViewModel.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-06-23.
//

import SwiftUI
import CoreLocation
import ImageIO
import MapKit
import Photos

@MainActor
class PhotoDetailsViewModel: ObservableObject {
    @Published var imageItem: ImageItem
    @Published var image: UIImage?
    @Published var metadata: PhotoMetadata
    @Published var locationText: String = "Loading location..."
    @Published var showSavedConfirmation: Bool = false

    private var fullImage: UIImage?

    init(imageItem: ImageItem) {
        self.imageItem = imageItem
        self.metadata = imageItem.metadata
        
        let screenW = UIScreen.main.bounds.width
        let scale   = UIScreen.main.scale
        
        self.image  = downsampleImage(
            at: imageItem.imageURL,
            to: CGSize(width: screenW, height: screenW),
            scale: scale
        )
        Task { await loadLocationText() }
    }

    func loadFullImageIfNeeded() {
        if fullImage == nil {
            fullImage = UIImage(contentsOfFile: imageItem.imageURL.path)
        }
    }

    var editingImage: UIImage {
        fullImage ?? image ?? UIImage()
    }
    
    func releaseFullImage() {
        fullImage = nil
    }

    func deletePhoto() {
        do {
            try FileManager.default.removeItem(at: imageItem.imageURL)
            print("Photo deleted successfully")
        } catch {
            print("Error deleting photo: \(error)")
        }
    }

    func saveToPhoneLibrary() async -> (success: Bool, error: String?) {
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard status == .authorized || status == .limited else {
                return (false, "Photo Library permission denied")
            }

            do {
                try await PHPhotoLibrary.shared().performChanges {
                    let req = PHAssetCreationRequest.forAsset()
                    req.addResource(with: .photo, fileURL: self.imageItem.imageURL, options: nil)
                }
                return (true, nil)
            } catch {
                return (false, error.localizedDescription)
            }
        }
    
    func removeAllMetadata() async {
        metadata.removeAllMetadata()
        await reload()
    }

    func loadLocationText() async {
        guard let coordinate = locationCoordinate else {
            self.locationText = "No location set"
            return
        }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        do {
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                self.locationText = [placemark.name,
                                     placemark.locality,
                                     placemark.administrativeArea,
                                     placemark.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
            } else {
                self.locationText = "Unknown location"
            }
        } catch {
            self.locationText = "Failed to load location"
        }
    }

    func reload() async {
            metadata.loadMetadata()

        let screenW = UIScreen.main.bounds.width
        let scale   = UIScreen.main.scale
        self.image  = downsampleImage(
            at: imageItem.imageURL,
            to: CGSize(width: screenW, height: screenW),
            scale: scale
        )

            let newMetadata = PhotoMetadata(imageURL: imageItem.imageURL)
            self.imageItem = ImageItem(url: imageItem.imageURL, metadata: newMetadata)

            fullImage = nil

            await loadLocationText()
        }

    var imageName: String {
        imageItem.imageURL.lastPathComponent
    }

    var resolution: String {
            let w = metadata.properties[kCGImagePropertyPixelWidth as String]  as? Int
            let h = metadata.properties[kCGImagePropertyPixelHeight as String] as? Int
            guard let w, let h else { return "-" }
            return "\(w) × \(h)"
        }

    var fileSize: String {
        guard let attr = try? FileManager.default.attributesOfItem(atPath: imageItem.imageURL.path),
              let size = attr[.size] as? Int else { return "-" }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }

    var fileType: String {
        imageItem.imageURL.pathExtension.uppercased()
    }

    var photoDate: String {
        if let date = exifDate {
            return MetadataFormatter.dateFormatter.string(from: date)
        }
        return "-"
    }

    var photoTime: String {
        if let date = exifDate {
            return MetadataFormatter.timeFormatter.string(from: date)
        }
        return "-"
    }

    var deviceModel: String {
        deviceModelValue ?? "-"
    }

    var locationCoordinate: CLLocationCoordinate2D? {
        guard let gps = metadata.properties[kCGImagePropertyGPSDictionary as String] as? [String: Any],
              let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double,
              let latRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String,
              let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double,
              let lonRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String else {
            return nil
        }

        let latitude = (latRef == "S") ? -lat : lat
        let longitude = (lonRef == "W") ? -lon : lon

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var exifDate: Date? {
        if let exif = metadata.properties[kCGImagePropertyExifDictionary as String] as? [String: Any],
           let raw = exif["DateTimeOriginal"] as? String {
            return MetadataFormatter.parseExifDate(from: raw)
        }
        return nil
    }

    var deviceModelValue: String? {
        if let tiff = metadata.properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any],
           let model = tiff["Model"] as? String {
            return model
        }
        return nil
    }
}
