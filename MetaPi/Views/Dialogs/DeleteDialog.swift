//
//  DeleteDialog.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-26.
//

import SwiftUI

struct DeleteDialog: View {
    var onDelete: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image("warning_icon")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.top, 12)
                .foregroundStyle(.primaryBlue)

            VStack(spacing: 4) {
                Text("Photos will be deleted.\n Are you sure?")
                    .font(AppFont.inter(.regular, size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.textBlack)
                    .padding(.horizontal, 16)

                Text("This deletes photos from app, not device.")
                    .font(AppFont.inter(.regular, size: 12))
                    .foregroundStyle(.textHighlight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            HStack(spacing: 8) {
                
                AppButton(title: "Delete", action: onDelete, style: .destructive, fullWidth: true)
                
                AppButton(title: "Cancel", action: onCancel, style: .secondary, fullWidth: true)

            }
            .padding(.top, 10)
            .padding(.horizontal, 16)
        }
        .frame(width: 286, height: 231)
        .background(.backgroundWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
    }
}
