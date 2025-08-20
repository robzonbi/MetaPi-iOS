//
//  SelectionActionBar.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-26.
//

import SwiftUI

struct SelectionActionBar: View {
    var selectedCount: Int
    var onDelete: () -> Void
    var onShare: () -> Void
    var onSave: () -> Void
    var onEdit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            Text("Photos Selected: \(selectedCount)")
                .font(AppFont.inter(.regular, size: 12))
                .foregroundStyle(.secondary)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 24) {
                ActionButton(icon: "delete_icon_circle", title: "Delete", action: onDelete)
                ActionButton(icon: "save_icon_circle", title: "Save", action: onSave)
                ActionButton(icon: "share_icon_circle", title: "Share", action: onShare)
                ActionButton(icon: "edit_icon_circle", title: "Metadata", action: onEdit)
            }
            .padding(.top, 16)
            .padding(.bottom, 32)
            .padding(.horizontal, 24)
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .background(.backgroundWhite)
    }
}

private struct ActionButton: View {
    var icon: String
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                
                Text(title)
                    .font(AppFont.inter(.regular, size: 14))
                    .foregroundStyle(.textBlack)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
