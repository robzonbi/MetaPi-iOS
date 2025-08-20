//
//  EditableMetadataKeyMaps.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-06-27.
//

import Foundation
import ImageIO

let editableIPTCMap: [(CFString, String)] = [
    (kCGImagePropertyIPTCObjectName, "Title"),
    (kCGImagePropertyIPTCHeadline, "Headline"),
    (kCGImagePropertyIPTCCaptionAbstract, "Caption"),
    (kCGImagePropertyIPTCKeywords, "Keywords"),
    (kCGImagePropertyIPTCCity, "City"),
    (kCGImagePropertyIPTCProvinceState, "State"),
    (kCGImagePropertyIPTCCountryPrimaryLocationName, "Country"),
    (kCGImagePropertyIPTCByline, "Author"),
    (kCGImagePropertyIPTCCopyrightNotice, "Copyright"),
    (kCGImagePropertyIPTCSource, "Image Source")
]

let editableEXIFMap: [(CFString, String)] = [
    (kCGImagePropertyExifFocalLength, "Focal Length"),
    (kCGImagePropertyExifFocalLenIn35mmFilm, "Focal Length (35mm)"),
    (kCGImagePropertyExifFNumber, "F Number"),
    (kCGImagePropertyExifISOSpeedRatings, "ISO Speed"),
    (kCGImagePropertyExifDigitalZoomRatio, "Digital Zoom"),
    (kCGImagePropertyExifExposureBiasValue, "Exposure Bias"),
    (kCGImagePropertyExifExposureTime, "Exposure Time"),
    (kCGImagePropertyExifLensModel, "Lens Model"),
    (kCGImagePropertyExifLensMake, "Lens Make"),
    (kCGImagePropertyExifLensSerialNumber, "Lens Serial Number"),
    (kCGImagePropertyTIFFMake, "Camera Make"),
    (kCGImagePropertyTIFFModel, "Camera Model"),
    (kCGImagePropertyTIFFSoftware, "Software"),
    (kCGImagePropertyExifUserComment, "User Comment")
]

