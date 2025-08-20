//
//  FontUtil.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-22.
//

import SwiftUI

enum AppFont {
    static func inter(_ weight: Font.Weight, size: CGFloat) -> Font {
        switch weight {
        case .bold: return .custom("Inter18pt-Bold", size: size)
        case .semibold: return .custom("Inter18pt-SemiBold", size: size)
        case .medium: return .custom("Inter18pt-Medium", size: size)
        default: return .custom("Inter18pt-Regular", size: size)
        }
    }
}

extension AppFont {
    static func interUIFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont(name: "Inter-\(weightName(weight))", size: size)
        ?? UIFont.systemFont(ofSize: size, weight: weight)
    }

    private static func weightName(_ weight: UIFont.Weight) -> String {
        switch weight {
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .bold: return "Bold"
        case .semibold: return "SemiBold"
        default: return "Regular"
        }
    }
}
