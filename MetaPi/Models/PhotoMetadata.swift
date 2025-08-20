//
//  PhotoMetadata.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-06-27.
//

import Foundation
import ImageIO
import UIKit
import UniformTypeIdentifiers

class PhotoMetadata: ObservableObject {
    @Published private(set) var properties: [String: Any] = [:]
    private let imageURL: URL

    init(imageURL: URL) {
        self.imageURL = imageURL
        loadMetadata()
    }

    func loadMetadata() {
        let opts: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceShouldCacheImmediately: false,
        ]
        guard
            let src = CGImageSourceCreateWithURL(
                imageURL as CFURL,
                opts as CFDictionary
            ),
            let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil)
                as? [String: Any]
        else {
            print("Failed to load metadata.")
            return
        }
        properties = props
    }

    var dateTimeOriginal: Date? {
        guard
            let exif = properties[kCGImagePropertyExifDictionary as String]
                as? [String: Any],
            let dateString = exif[
                kCGImagePropertyExifDateTimeOriginal as String
            ] as? String
        else {
            return nil
        }
        return Self.dateFromExifString(dateString)
    }

    var dateTimeDigitized: Date? {
        guard
            let exif = properties[kCGImagePropertyExifDictionary as String]
                as? [String: Any],
            let dateString = exif[
                kCGImagePropertyExifDateTimeDigitized as String
            ] as? String
        else {
            return nil
        }
        return Self.dateFromExifString(dateString)
    }

    private static func dateFromExifString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: string)
    }

    func saveMetadata(updatedProperties: [String: Any]) {
        guard let source = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
            let uti = CGImageSourceGetType(source),
            let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil),
            let originalProps = CGImageSourceCopyPropertiesAtIndex(
                source,
                0,
                nil
            ) as? [String: Any]
        else {
            print("Failed to prepare image for writing.")
            return
        }

        var mergedProps = originalProps

        for (key, updatedValue) in updatedProperties {
            if let updatedDict = updatedValue as? [String: Any] {
                if updatedDict.isEmpty {
                    mergedProps.removeValue(forKey: key)
                } else if var existingDict = mergedProps[key] as? [String: Any]
                {
                    for (innerKey, value) in updatedDict {
                        existingDict[innerKey] = value
                    }
                    mergedProps[key] = existingDict
                } else {
                    mergedProps[key] = updatedDict
                }
            } else {
                mergedProps[key] = updatedValue
            }
        }

        guard
            let dest = CGImageDestinationCreateWithURL(
                imageURL as CFURL,
                uti,
                1,
                nil
            )
        else {
            print("Failed to create destination.")
            return
        }

        CGImageDestinationAddImage(dest, cgImage, mergedProps as CFDictionary)

        if CGImageDestinationFinalize(dest) {
            print(
                "Metadata saved to disk. Reloading from disk for consistency."
            )
            loadMetadata()
        } else {
            print("Failed to write metadata.")
        }
    }

    func removeAllMetadata() {
        guard let ui = UIImage(contentsOfFile: imageURL.path) else {
            print("Failed to load UIImage.")
            return
        }

        let upright = ui.normalizedImage()
        guard let cg = upright.cgImage else {
            print("Failed to get CGImage from normalized image.")
            return
        }

        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")

        guard
            let dst = CGImageDestinationCreateWithURL(
                tmpURL as CFURL,
                UTType.jpeg.identifier as CFString,
                1,
                nil
            )
        else {
            print("Failed to create JPEG destination.")
            return
        }

        CGImageDestinationAddImage(
            dst,
            cg,
            [kCGImageDestinationLossyCompressionQuality: 1.0] as CFDictionary
        )

        guard CGImageDestinationFinalize(dst) else {
            print("Failed to finalize JPEG without metadata.")
            return
        }

        do {
            try FileManager.default.removeItem(at: imageURL)
            try FileManager.default.moveItem(at: tmpURL, to: imageURL)
            loadMetadata()
        } catch {
            print("Error replacing JPEG: \(error)")
            try? FileManager.default.removeItem(at: tmpURL)
        }
    }
}
