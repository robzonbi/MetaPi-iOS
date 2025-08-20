//
//  AppButton.swift
//  MetaPi
//
//  Created by Yuhang Zhou on 2025-07-14.
//

import SwiftUI

struct AppButton: View {
    var title: String
    var action: () -> Void
    var style: Style = .primary
    var size: Size = .regular
    var icon: String?
    var fullWidth: Bool = false

    enum Style {
        case primary, secondary, destructive
    }
    
    enum Size {
        case regular, small
    }

    var body: some View {
        Button(action: action) {
            if icon != nil {
                HStack (spacing: 8) {
                    Image(icon ?? "add_icon")
                        .resizable()
                        .frame(width: fontSize, height: fontSize)
                        .foregroundStyle(foreground)
                    
                    Text(title)
                        .font(AppFont.inter(.medium, size: fontSize))
                        .foregroundStyle(foreground)
                }
                .padding(.horizontal, padding)
                .frame(
                    minWidth: .none,
                    maxWidth: fullWidth ? .infinity : .none,
                    minHeight: height,
                    maxHeight: height
                )
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            } else {
                Text(title)
                    .font(AppFont.inter(.medium, size: fontSize))
                    .padding(.horizontal, padding)
                    .frame(
                        minWidth: .none,
                        maxWidth: fullWidth ? .infinity : .none,
                        minHeight: height,
                        maxHeight: height
                    )
                    .background(background)
                    .foregroundStyle(foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var background: Color {
        switch style {
        case .primary:
            return .buttonPrimaryBg
        case .secondary:
            return .buttonSecondaryBg
        case .destructive:
            return .buttonDestructiveBg
        }
    }

    private var foreground: Color {
        switch style {
        case .primary:
            return .buttonTextWhite
        case .secondary:
            return .buttonTextPrimary
        case .destructive:
            return .buttonTextWhite
        }
    }
    
    private var height: CGFloat {
        switch size {
        case .regular:
            return 44
        case .small:
            return 24
        }
    }
    
    private var padding: CGFloat {
        switch size {
        case .regular:
            return 20
        case .small:
            return 12
        }
    }
    
    private var fontSize: CGFloat {
        switch size {
        case .regular:
            return 16
        case .small:
            return 13
        }
    }
}
