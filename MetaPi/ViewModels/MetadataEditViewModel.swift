//
//  MetadataEditViewModel.swift
//  MetaPiAdd commentMore actions
//
//  Created by Veronika Nizhankivska on 2025-06-26.
//

import Foundation
import CoreLocation
import ImageIO

struct EditableMetadataField: Identifiable, Hashable {
    let id = UUID()
    let key: String
    let label: String
    var value: String {
        didSet { isModified = true }
    }
    var isModified: Bool = false
}

enum MetadataFilter: String, CaseIterable, Identifiable {
    case all = "All Tags"
    case iptc = "IPTC"
    case exif = "EXIF"
    case pi3d = "Pi3D"
    
    var id: String { rawValue }
}

extension MetadataFilter {
    init(defaultTag: DefaultMetadataTag) {
        switch defaultTag {
        case .allTags: self = .all
        case .exif: self = .exif
        case .iptc: self = .iptc
        case .pi3d: self = .pi3d
        }
    }
}

class MetadataEditViewModel: ObservableObject{
    @Published var dateTaken: Date
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var locationText: String = "No location set"
    @Published var selectedFilter: MetadataFilter
    @Published var hasChanges: Bool = false

    
    @Published var iptcFields: [EditableMetadataField] = []
    @Published var exifFields: [EditableMetadataField] = []
    
    @Published var showInfoAlert: Bool = false
    @Published var activeInfoLabel: String = ""
    var updatedProps: [String: Any] = [:]
    
    var activeInfoMessage: String {
        TagLabels.shared.message(for: activeInfoLabel)
    }
    
    
    private let photoMetadata: PhotoMetadata
    
    init(photoMetadata: PhotoMetadata) {
            self.photoMetadata = photoMetadata
            self.selectedFilter = MetadataFilter(defaultTag: UserPreferences.shared.tags)
            self.dateTaken = MetadataEditViewModel.resolveInitialDate(from: photoMetadata.properties)
            
            loadEditableFields()
        }
    
    
    private static func resolveInitialDate(from props: [String: Any]) -> Date {
            let iptc = props[kCGImagePropertyIPTCDictionary as String] as? [String: Any] ?? [:]
            if let dateStr = iptc[kCGImagePropertyIPTCDateCreated as String] as? String,
               let timeStr = iptc[kCGImagePropertyIPTCTimeCreated as String] as? String {
                let df = DateFormatter()
                df.dateFormat = "yyyyMMddHHmmss"
                df.timeZone = TimeZone(secondsFromGMT: 0)
                if let parsed = df.date(from: dateStr + timeStr) {
                    return parsed
                }
            }

            let exif = props[kCGImagePropertyExifDictionary as String] as? [String: Any] ?? [:]
            if let exifDateStr = exif[kCGImagePropertyExifDateTimeOriginal as String] as? String,
               let parsed = MetadataFormatter.parseExifDate(from: exifDateStr) {
                return parsed
            }

            return Date()
        }
    
    func loadEditableFields() {
        let props = photoMetadata.properties
        
        let iptc = props[kCGImagePropertyIPTCDictionary as String] as? [String: Any] ?? [:]
        let exif = props[kCGImagePropertyExifDictionary as String] as? [String: Any] ?? [:]
        let tiff = props[kCGImagePropertyTIFFDictionary as String] as? [String: Any] ?? [:]
        let merged = exif.merging(tiff) { exifVal, _ in exifVal }
        
        
        iptcFields = extractEditableFields(from: iptc, using: editableIPTCMap)
        exifFields = extractEditableFields(from: merged, using: editableEXIFMap)
        
        if let gps = props[kCGImagePropertyGPSDictionary as String] as? [String: Any],
           let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double,
           let latRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String,
           let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double,
           let lonRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String {
            
            let latitude = (latRef == "S") ? -lat : lat
            let longitude = (lonRef == "W") ? -lon : lon
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    
    func removeLocation() {
        coordinate = nil
        locationText = "No location set"
    }
    
    func saveChanges() {
        var updatedIPTC: [String: Any] = [:]
        var updatedEXIF: [String: Any] = [:]
        var updatedTIFF: [String: Any] = [:]
        var updatedGPS: [String: Any] = [:]
        
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let tf = DateFormatter()
        tf.dateFormat = "HHmmss"
        
        updatedIPTC[kCGImagePropertyIPTCDateCreated as String] = df.string(from: dateTaken)
        updatedIPTC[kCGImagePropertyIPTCTimeCreated as String] = tf.string(from: dateTaken)
        
        let now = Date()
        updatedIPTC[kCGImagePropertyIPTCDigitalCreationDate as String] = MetadataFormatter.iptcDateString(from: now)
        updatedIPTC[kCGImagePropertyIPTCDigitalCreationTime as String] = MetadataFormatter.iptcTimeString(from: now)
        
        
        for field in exifFields {
            let key = field.key as CFString
            let value = field.value.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if [kCGImagePropertyTIFFMake, kCGImagePropertyTIFFModel, kCGImagePropertyTIFFSoftware].contains(key) {
                updatedTIFF[key as String] = value
            } else {
                if let number = Double(value) {
                    updatedEXIF[key as String] = number
                } else {
                    updatedEXIF[key as String] = value
                }
            }
        }
        
        
        let keywordsKey = kCGImagePropertyIPTCKeywords as String
        let bylineKey = kCGImagePropertyIPTCByline as String
        
        for field in iptcFields {
            switch field.key {
            case keywordsKey, bylineKey:
                updatedIPTC[field.key] = MetadataFormatter.arrayFromCommaSeparatedString(field.value)
                
            default:
                updatedIPTC[field.key] = field.value
            }
        }
        
        
        if let coordinate = coordinate {
            updatedGPS[kCGImagePropertyGPSLatitude as String] = abs(coordinate.latitude)
            updatedGPS[kCGImagePropertyGPSLatitudeRef as String] = coordinate.latitude >= 0 ? "N" : "S"
            updatedGPS[kCGImagePropertyGPSLongitude as String] = abs(coordinate.longitude)
            updatedGPS[kCGImagePropertyGPSLongitudeRef as String] = coordinate.longitude >= 0 ? "E" : "W"
        } else {
            updatedProps[kCGImagePropertyGPSDictionary as String] = [:]
        }
        
        let updatedProps: [String: Any] = [
            kCGImagePropertyIPTCDictionary as String: updatedIPTC,
            kCGImagePropertyExifDictionary as String: updatedEXIF,
            kCGImagePropertyTIFFDictionary as String: updatedTIFF,
            kCGImagePropertyGPSDictionary as String: updatedGPS
        ]
        
        photoMetadata.saveMetadata(updatedProperties: updatedProps)
        hasChanges = true
        
    }
    
    private func extractEditableFields(from dict: [String: Any], using map: [(CFString, String)]) -> [EditableMetadataField] {
        map.map { key, label in
            let raw = dict[key as String]
            let value = raw.map { MetadataFormatter.formatRawMetadataValue($0) } ?? ""
            return EditableMetadataField(key: key as String, label: label, value: value)
        }
    }
    
    @MainActor
    func loadLocationText() async {
        guard let coordinate = coordinate else {
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
}

