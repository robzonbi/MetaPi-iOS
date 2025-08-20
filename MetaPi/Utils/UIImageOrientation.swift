//
//  UIImageOrientation.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-08-09.
//


import UIKit

extension UIImage {
    
    // Returns an upright (.up) version of the image by re-rendering pixels if needed.
    
    func normalizedImage() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
