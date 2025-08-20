//
//  InfoColumn.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-25.
//

import SwiftUI

struct InfoColumn: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppFont.inter(.regular, size: 12))
                .foregroundStyle(.textHighlight)

            Text(value.isEmpty ? "-" : value)
                .font(AppFont.inter(.medium, size: 14))
                .foregroundStyle(.textBlack)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}
