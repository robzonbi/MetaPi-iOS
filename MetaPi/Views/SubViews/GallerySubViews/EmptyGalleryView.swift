//
//  EmptyGalleryView.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-23.
//

import SwiftUI

struct EmptyGalleryView: View {
    let onImportTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text("Your gallery is empty")
                .font(AppFont.inter(.regular, size: 16))
                .foregroundStyle(.textBlack)
                .padding(.vertical, 4)
            
            VStack {
                AppButton(
                    title: "Import Photos",
                    action: onImportTap,
                    icon: "add_icon",
                    fullWidth: true)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
