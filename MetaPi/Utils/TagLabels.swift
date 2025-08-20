//
//  TagLabels.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-08-07.
//

import Foundation

struct TagLabels {
    static let shared = TagLabels()

    private let map: [String: String] = [
        
        // IPTC
        
        "Title": "Enter a short verbal and human readable name for the image, this may be the file name.",
        "Headline": "Enter a brief publishable synopsis or summary of the contents of the image.",
        "Caption": "Enter a caption describing the who, what, and why of what is happening in this image, this might include names of people, and/or their role in the action that is taking place within the image.",
        "Keywords": "Enter any number of keywords, terms or phrases to express the subject and other aspects of the content of the image.",
        "City": "Enter the name of the city pictured in this image.",
        "State": "Enter the name of the province or state pictured in this image.",
        "Country": "Enter the name of the country pictured in this image",
        "Author": "Enter the name of the person that created this image",
        "Copyright": "Enter a Notice on the current owner of the Copyright for this image, such as ©2008 Jane Doe.",
        "Image Source": "Enter the name of the person that created this image",
        
        // EXIF
        
        "Focal Length": "Focal length of lens used to take image. Unit is millimeter.",
        "Focal Length (35mm)": "Called FocalLengthIn35mmFilm by the EXIF spec.",
        "F Number": "The actual F-number(F-stop) of lens when the image was taken.",
        "ISO Speed": "CCD sensitivity equivalent to Ag-Hr film speedrate.",
        "Digital Zoom": "Shows Digital Zoom ratio. 0=normal, 2=digital 2x zoom.",
        "Exposure Bias": "Exposure bias value of taking picture. Unit is EV.",
        "Exposure Time": "Exposure time (reciprocal of shutter speed). Unit is second.",
        "Lens Model": "Shows model number of digicam lens.",
        "Camera Model": "Shows model number of digicam.",
        "Lens Make": "Shows manufacturer of digicam lens.",
        "Camera Make": "Shows manufacturer of digicam.",
        "Lens Serial Number": "Shows manufacturer of digicam lens.",
        "User Comment": "Stores user comment.",
        "Software": "Shows firmware(internal software of digicam) version number",
    ]

    func message(for key: String) -> String {
        map[key] ?? "No description available for this tag."
    }
}
