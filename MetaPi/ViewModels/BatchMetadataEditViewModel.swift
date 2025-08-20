//
//  BatchMetadataViewModel.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-08-01.
//

import Foundation
import CoreLocation
import ImageIO

class BatchMetadataEditViewModel: MetadataEditViewModel {
    private var allPhotoMetadata: [PhotoMetadata]
    private var isDateTakenModified = false
    var isLocationModified = false
    @Published var didRemoveLocation: Bool = false
    
    
    override var activeInfoMessage: String {
        TagLabels.shared.message(for: activeInfoLabel)
    }

    override var dateTaken: Date {
        didSet { isDateTakenModified = true }
    }

    override var coordinate: CLLocationCoordinate2D? {
        didSet {
            isLocationModified = true
        }
    }

    var photoCount: Int {
        allPhotoMetadata.count
    }

    init(photoMetadatas: [PhotoMetadata]) {
        self.allPhotoMetadata = photoMetadatas
        let dummyMetadata = PhotoMetadata(imageURL: URL(fileURLWithPath: "/dev/null"))
        super.init(photoMetadata: dummyMetadata)
        clearEditableFields()
    }
    
    override func removeLocation() {
        coordinate = nil
        didRemoveLocation = true
    }

    override func saveChanges() {
        var updatedProps: [String: Any] = [:]
        var updatedIPTC: [String: Any] = [:]
        var updatedEXIF: [String: Any] = [:]

        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let tf = DateFormatter()
        tf.dateFormat = "HHmmss"


        if isDateTakenModified {
            updatedIPTC[kCGImagePropertyIPTCDateCreated as String] = df.string(from: dateTaken)
            updatedIPTC[kCGImagePropertyIPTCTimeCreated as String] = tf.string(from: dateTaken)
        }

        for field in iptcFields where field.isModified && !field.value.isEmpty {
                updatedIPTC[field.key] = field.value
            }
            if !updatedIPTC.isEmpty {
                updatedProps[kCGImagePropertyIPTCDictionary as String] = updatedIPTC
            }

            for field in exifFields where field.isModified && !field.value.isEmpty {
                updatedEXIF[field.key] = field.value
            }
            if !updatedEXIF.isEmpty {
                updatedProps[kCGImagePropertyExifDictionary as String] = updatedEXIF
            }
        
        if didRemoveLocation {
            updatedProps[kCGImagePropertyGPSDictionary as String] = [:]
        } else if isLocationModified, let coordinate = coordinate {
            updatedProps[kCGImagePropertyGPSDictionary as String] = [
                kCGImagePropertyGPSLatitude as String: abs(coordinate.latitude),
                kCGImagePropertyGPSLatitudeRef as String: coordinate.latitude >= 0 ? "N" : "S",
                kCGImagePropertyGPSLongitude as String: abs(coordinate.longitude),
                kCGImagePropertyGPSLongitudeRef as String: coordinate.longitude >= 0 ? "E" : "W"
            ]
        }

        let shouldSave = !updatedProps.isEmpty || didRemoveLocation
        if shouldSave {
            for meta in allPhotoMetadata {
                meta.saveMetadata(updatedProperties: updatedProps)
            }
        }
    }

    private func clearEditableFields() {
        iptcFields = iptcFields.map { EditableMetadataField(key: $0.key, label: $0.label, value: "") }
        exifFields = exifFields.map { EditableMetadataField(key: $0.key, label: $0.label, value: "") }

        coordinate = nil
        locationText = "No location set"
        dateTaken = Date()
        isDateTakenModified = false
    }
}
