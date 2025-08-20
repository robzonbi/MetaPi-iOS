//
//  MetadaSegmentViewModel.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-06-25.
//
import Foundation
import CoreLocation
import ImageIO

struct MetadataDisplayItem {
    let key: String
    let label: String
    let value: String
}

struct MetadataDisplaySection {
    let title: String
    let items: [MetadataDisplayItem]
}

class MetadataSegmentViewModel: ObservableObject {
    @Published var sections: [MetadataDisplaySection] = []

    private let metadata: PhotoMetadata

    init(metadata: PhotoMetadata) {
        self.metadata = metadata
        buildSections()
    }

    func reload() {
        metadata.loadMetadata()
    }

    private func buildSections() {
        var result: [MetadataDisplaySection] = []

        let props = metadata.properties

        print("[DEBUG] --- FULL RAW METADATA ---")
        dumpProperties(props)
        print("[DEBUG] --- END OF RAW METADATA ---")

        // IPTC
        let iptc = props[kCGImagePropertyIPTCDictionary as String] as? [String: Any] ?? [:]
        let iptcItems = makeItems(from: iptc, using: iptcMap, formatter: MetadataFormatter.formatIPTCTag)
        result.append(MetadataDisplaySection(title: "IPTC Metadata", items: iptcItems))

        // EXIF
        let exif = props[kCGImagePropertyExifDictionary as String] as? [String: Any] ?? [:]
        result.append(MetadataDisplaySection(title: "EXIF Timestamps", items: makeItems(from: exif, using: exifTimestampMap, formatter: MetadataFormatter.formatExifDateTag)))
        result.append(MetadataDisplaySection(title: "EXIF Camera Settings", items: makeItems(from: exif, using: exifCameraSettingsMap, formatter: MetadataFormatter.formatExifTechnicalTags)))
        result.append(MetadataDisplaySection(title: "EXIF Image Quality", items: makeItems(from: exif, using: exifImageQualityMap, formatter: MetadataFormatter.formatExifTechnicalTags)))
        result.append(MetadataDisplaySection(title: "EXIF Image Settings", items: makeItems(from: exif, using: exifImageSettingsMap, formatter: MetadataFormatter.formatExifTechnicalTags)))
        result.append(MetadataDisplaySection(title: "EXIF Lens Info", items: makeItems(from: exif, using: exifLensInfoMap, formatter: MetadataFormatter.formatExifTechnicalTags)))

        let tiff = props[kCGImagePropertyTIFFDictionary as String] as? [String: Any] ?? [:]
        let tiffItems = makeItems(from: tiff, using: [
            (kCGImagePropertyTIFFMake, "Camera Make"),
            (kCGImagePropertyTIFFModel, "Camera Model"),
            (kCGImagePropertyTIFFSoftware, "Software")
        ])

        let exifCameraNotesItems = makeItems(from: exif, using: [
            (kCGImagePropertyExifUserComment, "User Comment"),
            (kCGImagePropertyExifMakerNote, "Maker Notes")
        ])

        result.append(MetadataDisplaySection(title: "EXIF Camera Info", items: tiffItems + exifCameraNotesItems))
        
        
        // GPS
        let gps = props[kCGImagePropertyGPSDictionary as String] as? [String: Any] ?? [:]
        let gpsItems = makeItems(from: gps, using: gpsMap)
        result.append(MetadataDisplaySection(title: "GPS Metadata", items: gpsItems))

        // General
        let general = makeItems(from: props, using: generalMap, formatter: MetadataFormatter.formatGeneralMetadata)
        if !general.isEmpty {
            result.append(MetadataDisplaySection(title: "General Metadata", items: general))
        }

        sections = result
    }

    private func makeItems(
        from dict: [String: Any],
        using map: [(CFString, String)],
        formatter: ((CFString, Any?) -> String)? = nil
    ) -> [MetadataDisplayItem] {
        map.compactMap { (key, label) in
            let raw = dict[key as String]
            let formatted = formatter?(key, raw) ?? MetadataFormatter.formatRawMetadataValue(raw)
            return MetadataDisplayItem(
                key: key as String,
                label: label,
                value: formatted.isEmpty ? "-" : formatted
            )
        }
    }

    private func dumpProperties(_ dict: [String: Any], indent: String = "") {
        for (key, value) in dict {
            if let nested = value as? [String: Any] {
                print("\(indent)\(key):")
                dumpProperties(nested, indent: indent + "  ")
            } else if let array = value as? [Any] {
                print("\(indent)\(key): [")
                for item in array {
                    if let nestedItem = item as? [String: Any] {
                        dumpProperties(nestedItem, indent: indent + "  ")
                    } else {
                        print("\(indent)  \(item)")
                    }
                }
                print("\(indent)]")
            } else {
                print("\(indent)\(key): \(value)")
            }
        }
    }
}
