//
//  MetadataActionBarView.swift
//  MetaPi
//
//  Created by Yuhang Zhou on 2025-07-18.
//

import SwiftUI

enum MetadataTagFilters: String, CaseIterable, Identifiable {
    case allTags, exif, iptc, pi3d
    var id: String { rawValue }
}

import SwiftUI

import SwiftUI

struct MetadataActionBarView: View {
    @ObservedObject var viewModel: MetadataEditViewModel
    @StateObject var preferences = UserPreferences.shared

    init(viewModel: MetadataEditViewModel, preferences: UserPreferences = UserPreferences.shared) {
        self.viewModel = viewModel
        _preferences = StateObject(wrappedValue: preferences)
    }

    var body: some View {
        HStack {
            ForEach(MetadataFilter.allCases) { filter in
                let isSelected = filter == viewModel.selectedFilter
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedFilter = filter
                    }
                } label: {
                    Text(filter.rawValue)
                        .font(AppFont.inter(isSelected ? .medium : .regular, size: 13))
                        .foregroundColor(isSelected ? .buttonTextWhite : .buttonTextPrimary)
                        .frame(maxWidth: .infinity, minHeight: 24)
                        .padding(.vertical, 1)
                        .background(isSelected ? Color.buttonPrimaryBg : Color.buttonSecondaryBg)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.backgroundWhite)
    }
}
