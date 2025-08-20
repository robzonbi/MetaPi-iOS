//
//  GalleryActionBarDropDown.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-07-12.
//

import SwiftUI

struct GalleryActionBarDropDown: View {
    @Binding var selectedOption: SortOption
    var onOptionSelected: (SortOption) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(SortOption.allCases.indices, id: \.self) { index in
                let option = SortOption.allCases[index]
                
                Button(action: {
                    onOptionSelected(option)
                }) {
                    HStack {
                        Text(option.rawValue)
                            .font(AppFont.inter(.regular, size: 14))
                            .foregroundStyle(.textBlack)
                        
                        Spacer()
                        
                        if selectedOption == option {
                            Image("checkmark_icon")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(.textBlack)
                                .frame(width: 16, height: 16)
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 39)
                    .contentShape(Rectangle())
                }

                if index < SortOption.allCases.count - 1 {
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray.opacity(0.3))
                        
                }
            }
        }
        .frame(width: 250, height: 117)
        .background(.backgroundWhite)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
