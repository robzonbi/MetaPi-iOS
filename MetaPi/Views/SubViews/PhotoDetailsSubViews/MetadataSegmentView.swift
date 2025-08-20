//
//  MetadataSegmentView.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-06-23.
//

import SwiftUI

struct MetadataSegmentView: View {
    @ObservedObject var viewModel: MetadataSegmentViewModel
    @Binding var shouldReload: Bool

    @State private var expandedSections: Set<String> = []
    @State private var selectedValue: String? = nil
    @State private var reloadID = UUID()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.sections, id: \.title) { section in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedSections.contains(section.title) },
                            set: { isOpen in
                                if isOpen {
                                    expandedSections.insert(section.title)
                                } else {
                                    expandedSections.remove(section.title)
                                }
                            }
                        ),
                        content: {
                            VStack(spacing: 8) {
                                ForEach(section.items, id: \.key) { item in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(alignment: .top) {
                                            Text(item.label)
                                                .font(AppFont.inter(.regular, size: 14))
                                                .foregroundStyle(.textBlack)
                                                .frame(minWidth: 100, alignment: .leading)

                                            Spacer()

                                            Text(displayedValue(for: item.value))
                                                .font(AppFont.inter(.regular, size: 14))
                                                .foregroundStyle(.textBlack.opacity(0.7))
                                                .multilineTextAlignment(.trailing)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .onTapGesture {
                                                    if item.value.count > 25 {
                                                        selectedValue = item.value
                                                    }
                                                }
                                        }
                                        Divider()
                                    }
                                }
                            }
                            .padding(.top, 8)
                        },
                        label: {
                            Text(section.title)
                                .font(AppFont.inter(.bold, size: 14))
                                .foregroundStyle(.textHighlight)
                        }
                    )
                    .tint(.primaryBlue)
                }
            }
            .padding()
        }
        .onAppear {
            expandedSections = Set(viewModel.sections.map { $0.title })
        }
        .id(reloadID)
        .task(id: reloadID) {
            if shouldReload {
                viewModel.reload()
                shouldReload = false
            }
        }
        .alert("Full Value", isPresented: Binding(
            get: { selectedValue != nil },
            set: { newValue in if !newValue { selectedValue = nil } }
        )) {
            Button("OK", role: .cancel) { selectedValue = nil }
        } message: {
            Text(selectedValue ?? "")
        }
    }

    private func displayedValue(for value: String) -> String {
        value.count > 25 ? value.prefix(25) + "…" : value
    }
}
