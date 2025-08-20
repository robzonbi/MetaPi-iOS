//
//  MetadataFormatter.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-25.
//

import Foundation
import ImageIO

struct MetadataFormatter {

    private struct Descriptions {
        static let exposureProgram = [
            0: "Not Defined", 1: "Manual", 2: "Normal Program", 3: "Aperture Priority",
            4: "Shutter Priority", 5: "Creative Program", 6: "Action Program",
            7: "Portrait Mode", 8: "Landscape Mode"
        ]

        static let exposureMode = [0: "Auto Exposure", 1: "Manual", 2: "Auto Bracket"]
        static let whiteBalance = [0: "Auto", 1: "Manual"]
        static let meteringMode = [
            0: "Unknown", 1: "Average", 2: "Center Weighted Average", 3: "Spot",
            4: "Multi-spot", 5: "Multi-segment", 6: "Partial", 255: "Other"
        ]
        static let sensingMethod = [
            1: "Not Defined", 2: "One-chip Color Area Sensor", 3: "Two-chip Color Area Sensor",
            4: "Three-chip Color Area Sensor", 5: "Color Sequential Area Sensor",
            7: "Trilinear Sensor", 8: "Other"
        ]
        static let sceneCaptureType = [0: "Standard", 1: "Landscape", 2: "Portrait", 3: "Night Scene"]
        static let lightSource = [
            0: "Unknown", 1: "Daylight", 2: "Fluorescent", 3: "Tungsten", 4: "Flash",
            9: "Fine Weather", 10: "Cloudy", 11: "Shade", 12: "Daylight Fluorescent",
            13: "Day White Fluorescent", 14: "Cool White Fluorescent", 15: "White Fluorescent",
            17: "Standard Light A", 18: "Standard Light B", 19: "Standard Light C",
            20: "D55", 21: "D65", 22: "D75", 23: "D50", 24: "ISO Studio Tungsten", 255: "Other"
        ]
        static let flash = [
            0x0: "Flash did not fire", 0x1: "Flash fired", 0x5: "Flash fired, no return",
            0x7: "Flash fired, return detected", 0x9: "Compulsory flash fired",
            0xD: "Compulsory flash, no return", 0xF: "Compulsory flash, return detected",
            0x10: "Flash not fired (compulsory)", 0x18: "Auto, flash not fired",
            0x19: "Auto, flash fired", 0x1D: "Auto, no return", 0x1F: "Auto, return detected",
            0x20: "No flash function", 0x41: "Red-eye, flash fired",
            0x45: "Red-eye, no return", 0x47: "Red-eye, return detected"
        ]
        static let colorSpace = [1: "sRGB", 65535: "Uncalibrated"]
        static let gainControl = [
            0: "None", 1: "Low Gain Up", 2: "High Gain Up",
            3: "Low Gain Down", 4: "High Gain Down"
        ]
        static let customRendered = [0: "Normal", 1: "Custom"]
        static let fileSource = [1: "Film Scanner", 2: "Reflection Print Scanner", 3: "Digital Camera"]
        static let orientation = [
            1: "Top-left", 2: "Top-right", 3: "Bottom-right", 4: "Bottom-left",
            5: "Left-top", 6: "Right-top", 7: "Right-bottom", 8: "Left-bottom"
        ]
    }

    static let dateFormatter: DateFormatter = {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none
            return df
        }()

        static let timeFormatter: DateFormatter = {
            let tf = DateFormatter()
            tf.dateStyle = .none
            tf.timeStyle = .short
            return tf
        }()

        static func parseExifDate(from string: String) -> Date? {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            return formatter.date(from: string)
        }
        static func exifDateString(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            return formatter.string(from: date)
        }

        
        static func iptcDateString(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            return formatter.string(from: date)
        }

        static func parseIptcDate(from string: String) -> Date? {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            return formatter.date(from: string)
        }
        
        static func parseIptcTime(from string: String) -> Date? {
            let formatter = DateFormatter()
            formatter.dateFormat = "HHmmss"
            return formatter.date(from: string)
        }

        static func iptcTimeString(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HHmmss"
            return formatter.string(from: date)
        }
    
    static func formatIPTCTag(for key: CFString, value: Any?) -> String {
        switch key {
        case kCGImagePropertyIPTCKeywords,
             kCGImagePropertyIPTCByline:
            return formatRawMetadataValue(value, separator: ", ")
        default:
            return formatRawMetadataValue(value)
        }
    }

    static func formatExifDateTag(for key: CFString, value: Any?) -> String {
        guard let raw = value as? String else { return "-" }

        if key == kCGImagePropertyExifDateTimeOriginal || key == kCGImagePropertyExifDateTimeDigitized {
            let datePart = raw.prefix(10).replacingOccurrences(of: ":", with: "/")
            let timePart = raw.dropFirst(11)
            return "\(datePart), \(timePart)"
        }

        return raw
    }

    static func formatRawMetadataValue(_ rawValue: Any?, separator: String = ", ") -> String {
        if let array = rawValue as? [Any] {
            return array.map { "\($0)" }.joined(separator: separator)
        } else if let value = rawValue {
            return "\(value)"
        } else {
            return "-"
        }
    }
    
    static func arrayFromCommaSeparatedString(_ input: String) -> [String] {
        input
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func formatExifVersion(from value: Any?) -> String {
        if let array = value as? [Int], array.count >= 2 {
            return array.prefix(2).map(String.init).joined(separator: ".")
        }
        return formatRawMetadataValue(value)
    }

    static func formatExifTechnicalTags(for key: CFString, value: Any?) -> String {
        guard let value = value else { return "-" }

        func formatFromMap<T: Hashable>(_ map: [T: String], as type: T.Type) -> String {
            if let casted = value as? T {
                return map[casted] ?? "Unrecognized (\(casted))"
            } else {
                return formatRawMetadataValue(value)
            }
        }

        switch key {
        case kCGImagePropertyExifExposureProgram:
            return formatFromMap(Descriptions.exposureProgram, as: Int.self)
        case kCGImagePropertyExifExposureMode:
            return formatFromMap(Descriptions.exposureMode, as: Int.self)
        case kCGImagePropertyExifWhiteBalance:
            return formatFromMap(Descriptions.whiteBalance, as: Int.self)
        case kCGImagePropertyExifMeteringMode:
            return formatFromMap(Descriptions.meteringMode, as: Int.self)
        case kCGImagePropertyExifSensingMethod:
            return formatFromMap(Descriptions.sensingMethod, as: Int.self)
        case kCGImagePropertyExifSceneCaptureType:
            return formatFromMap(Descriptions.sceneCaptureType, as: Int.self)
        case kCGImagePropertyExifLightSource:
            return formatFromMap(Descriptions.lightSource, as: Int.self)
        case kCGImagePropertyExifFlash:
            return formatFromMap(Descriptions.flash, as: Int.self)
        case kCGImagePropertyExifColorSpace:
            return formatFromMap(Descriptions.colorSpace, as: Int.self)
        case kCGImagePropertyExifGainControl:
            return formatFromMap(Descriptions.gainControl, as: Int.self)
        case kCGImagePropertyExifCustomRendered:
            return formatFromMap(Descriptions.customRendered, as: Int.self)
        case kCGImagePropertyExifFileSource:
            return formatFromMap(Descriptions.fileSource, as: Int.self)
        case kCGImagePropertyExifExposureBiasValue:
            if let double = value as? Double, double.isFinite {
                return String(format: "%.1f EV", double)
            }
        case kCGImagePropertyExifExposureTime:
            if let seconds = value as? Double, seconds > 0, seconds.isFinite {
                return seconds >= 1.0 ?
                    String(format: "%.1fs", seconds) :
                    "1/\(Int(round(1.0 / seconds)))s"
            }
        case kCGImagePropertyExifFNumber:
            if let f = value as? Double, f.isFinite {
                return String(format: "f/%.1f", f)
            }
        case kCGImagePropertyExifFocalLength:
            if let mm = value as? Double, mm.isFinite {
                return String(format: "%.0f mm", mm)
            }
        case kCGImagePropertyExifFocalLenIn35mmFilm:
            if let mm = value as? Double, mm.isFinite {
                return String(format: "%.0f mm (35mm)", mm)
            }
        case kCGImagePropertyExifShutterSpeedValue:
            if let apex = value as? Double, apex.isFinite {
                let seconds = pow(2.0, -apex)
                if seconds > 0, seconds.isFinite {
                    return seconds >= 1.0 ?
                        String(format: "%.1fs", seconds) :
                        "1/\(Int(round(1.0 / seconds)))s"
                }
            }
        case kCGImagePropertyExifFlashPixVersion, kCGImagePropertyExifVersion:
            return formatExifVersion(from: value)
        default:
            break
        }

        return formatRawMetadataValue(value)
    }

    static func formatGeneralMetadata(for key: CFString, value: Any?) -> String {
        if key == kCGImagePropertyOrientation, let int = value as? Int {
            return Descriptions.orientation[int] ?? "Unrecognized (\(int))"
        }
        return formatRawMetadataValue(value)
    }
}
