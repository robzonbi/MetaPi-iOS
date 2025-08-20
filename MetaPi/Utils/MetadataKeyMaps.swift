//
//  MetadataMaps.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-06-25.
//
import Foundation
import ImageIO

let exifTimestampMap: [(CFString, String)] = [
    (kCGImagePropertyExifDateTimeOriginal, "Date Taken"),
    (kCGImagePropertyExifDateTimeDigitized, "Date Modified")
]

let exifCameraSettingsMap: [(CFString, String)] = [
    (kCGImagePropertyExifExposureProgram, "Exposure Program"),
    (kCGImagePropertyExifExposureMode, "Exposure Mode"),
    (kCGImagePropertyExifExposureBiasValue, "Exposure Bias"),
    (kCGImagePropertyExifExposureTime, "Exposure Time"),
    (kCGImagePropertyExifShutterSpeedValue, "Shutter Speed Value"),
    (kCGImagePropertyExifMeteringMode, "Metering Mode"),
    (kCGImagePropertyExifISOSpeedRatings, "ISO"),
    (kCGImagePropertyExifFNumber, "F Number"),
    (kCGImagePropertyExifApertureValue, "Aperture (APEX)"),
    (kCGImagePropertyExifMaxApertureValue, "Max Aperture (APEX)"),
    (kCGImagePropertyExifFocalLength, "Focal Length"),
    (kCGImagePropertyExifFocalLenIn35mmFilm, "Focal Length (35mm)"),
    (kCGImagePropertyExifWhiteBalance, "White Balance"),
    (kCGImagePropertyExifSensingMethod, "Sensing Method"),
    (kCGImagePropertyExifSceneCaptureType, "Scene Capture Type"),
    (kCGImagePropertyExifDigitalZoomRatio, "Digital Zoom"),
    (kCGImagePropertyExifSubjectArea, "Subject Area"),
    (kCGImagePropertyExifLightSource, "Light Source")
]


let exifImageQualityMap: [(CFString, String)] = [
    (kCGImagePropertyExifBrightnessValue, "Brightness"),
    (kCGImagePropertyExifContrast, "Contrast"),
    (kCGImagePropertyExifSaturation, "Saturation"),
    (kCGImagePropertyExifSharpness, "Sharpness"),
    (kCGImagePropertyExifFlash, "Flash")
]

let exifImageSettingsMap: [(CFString, String)] = [
    (kCGImagePropertyExifColorSpace, "Color Space"),
    (kCGImagePropertyExifGainControl, "Gain Control"),
    (kCGImagePropertyExifCustomRendered, "Custom Rendering"),
    (kCGImagePropertyExifFileSource, "File Source"),
    (kCGImagePropertyExifComponentsConfiguration, "Components Configuration"),
    (kCGImagePropertyExifFlashPixVersion, "FlashPix Version"),
    (kCGImagePropertyExifVersion, "EXIF Version")
]

let exifLensInfoMap: [(CFString, String)] = [
    (kCGImagePropertyExifLensModel, "Lens Model"),
    (kCGImagePropertyExifLensMake, "Lens Make"),
    (kCGImagePropertyExifLensSpecification, "Lens Specification"),
    (kCGImagePropertyExifLensSerialNumber, "Lens Serial Number")
]

let exifCameraInfoMap: [(CFString, String)] = [
    (kCGImagePropertyTIFFMake, "Camera Make"),
    (kCGImagePropertyTIFFModel, "Camera Model"),
    (kCGImagePropertyExifUserComment, "User Comment"),
    (kCGImagePropertyExifMakerNote, "Maker Notes"),
    (kCGImagePropertyTIFFSoftware, "Software")
]

let gpsMap: [(CFString, String)] = [
    (kCGImagePropertyGPSLatitude, "Latitude"),
    (kCGImagePropertyGPSLatitudeRef, "Latitude Ref"),
    (kCGImagePropertyGPSLongitude, "Longitude"),
    (kCGImagePropertyGPSLongitudeRef, "Longitude Ref")
]

let iptcMap: [(CFString, String)] = [
    (kCGImagePropertyIPTCObjectName, "Title"),
    (kCGImagePropertyIPTCHeadline, "Headline"),
    (kCGImagePropertyIPTCCaptionAbstract, "Caption"),
    (kCGImagePropertyIPTCKeywords, "Keywords"),
    (kCGImagePropertyIPTCCity, "City"),
    (kCGImagePropertyIPTCProvinceState, "State"),
    (kCGImagePropertyIPTCCountryPrimaryLocationName, "Country"),
    (kCGImagePropertyIPTCByline, "Author"),
    (kCGImagePropertyIPTCCopyrightNotice, "Copyright"),
    (kCGImagePropertyIPTCSource, "Image Source"),
]

let generalMap: [(CFString, String)] = [
    (kCGImagePropertyColorModel, "Color Model"),
    (kCGImagePropertyDepth, "Bit Depth"),
    (kCGImagePropertyProfileName, "Color Profile"),
    (kCGImagePropertyOrientation, "Orientation"),
]
