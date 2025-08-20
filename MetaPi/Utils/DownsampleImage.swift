//
//  Downsample.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-08-09.
//

import ImageIO
import UIKit

func downsampleImage(at url: URL, to targetSize: CGSize, scale: CGFloat) -> UIImage? {
    let maxDimension = Int(max(targetSize.width, targetSize.height) * scale)

    let srcOpts: [CFString: Any] = [
        kCGImageSourceShouldCache: false,
        kCGImageSourceShouldCacheImmediately: false
    ]
    guard let src = CGImageSourceCreateWithURL(url as CFURL, srcOpts as CFDictionary) else { return nil }

    let thumbOpts: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
        kCGImageSourceThumbnailMaxPixelSize: maxDimension,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: true
    ]
    guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, thumbOpts as CFDictionary) else { return nil }
    return UIImage(cgImage: cg, scale: scale, orientation: .up)
}
