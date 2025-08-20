//
//  AlertDialog.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-07-13.
//

import SwiftUI

struct AlertDialog: View {
    var iconName: String
    var message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(iconName)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.primaryBlue)

            Text(message)
                .font(AppFont.inter(.regular, size: 16))
                .foregroundStyle(.textBlack)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .frame(width: 286, height: 200)
        .background(.backgroundWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

