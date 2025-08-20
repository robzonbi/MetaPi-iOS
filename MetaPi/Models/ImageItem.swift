//
//  ImageItem.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-06-02
//

import SwiftUI
import Foundation

struct ImageItem: Identifiable, Hashable {
       let id: String
       let imageURL: URL
       var metadata: PhotoMetadata

       init(url: URL, metadata: PhotoMetadata? = nil) {
           self.id = url.path
           self.imageURL = url
           self.metadata = metadata ?? PhotoMetadata(imageURL: url)
       }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    static func == (lhs: ImageItem, rhs: ImageItem) -> Bool { lhs.id == rhs.id }

    static var placeholder: ImageItem {
        ImageItem(
            url: URL(fileURLWithPath: "/dev/null"),
            metadata: PhotoMetadata(imageURL: URL(fileURLWithPath: "/dev/null"))
        )
    }

    // saving after cropping
    func saveEditedVersion(_ image: UIImage) -> Bool {
        
        let upright = image.normalizedImage()
        guard let cgImage = upright.cgImage else { return false }

        guard
            let source = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
            let uti = CGImageSourceGetType(source),
            let dest = CGImageDestinationCreateWithURL(imageURL as CFURL, uti, 1, nil)
        else { return false }

        var props = (CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]) ?? [:]

      
        props[kCGImagePropertyOrientation as String] = CGImagePropertyOrientation.up.rawValue
        var tiff = (props[kCGImagePropertyTIFFDictionary as String] as? [String: Any]) ?? [:]
        tiff[kCGImagePropertyTIFFOrientation as String] = 1
        props[kCGImagePropertyTIFFDictionary as String] = tiff

        var exif = (props[kCGImagePropertyExifDictionary as String] as? [String: Any]) ?? [:]
        exif[kCGImagePropertyExifPixelXDimension as String] = cgImage.width
        exif[kCGImagePropertyExifPixelYDimension as String] = cgImage.height
        props[kCGImagePropertyExifDictionary as String] = exif

        CGImageDestinationAddImage(dest, cgImage, props as CFDictionary)

        CGImageDestinationSetProperties(
            dest,
            [kCGImageDestinationLossyCompressionQuality as String: 1.0] as CFDictionary
        )

        return CGImageDestinationFinalize(dest)
    }

}
