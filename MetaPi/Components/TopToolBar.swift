//
//  TopToolBar.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-22.
//

import SwiftUI

struct TopToolbar: View {
    let isSelecting: Bool
    let iconName: String
    let action: () -> Void
    let onDone: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            if isSelecting {
                Spacer()
                    .frame(width: 24, height: 24)
            } else {
                Text("Gallery")
                    .font(AppFont.inter(.bold, size: 24))
                    .foregroundStyle(.textBlack)
            }

            Spacer()

            if isSelecting {
                Text("Select Photos")
                    .font(AppFont.inter(.bold, size: 16))
                    .foregroundStyle(.textBlack)
            }

            Spacer()

            if isSelecting {
                Button("Done", action: onDone)
                    .font(AppFont.inter(.bold, size: 16))
            } else {
                Button(action: action) {
                    Image(iconName)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.primaryBlue)
                }
            }
        }
        .frame(height: 64)
        .padding(.horizontal)
        .background(.backgroundWhite)
    }
}
