//
//  FAQView.swift
//  MetaPi
//
//  Created by Vinaydeep Singh Padda on 2025-08-01.
//

import SwiftUI

struct FAQView: View {
    private let sections: [FAQSectionModel] = FAQsData.all
    @Environment(\.dismiss) private var dismiss
    @State private var expandedIDs: Set<UUID> = []

    var body: some View {
        List {
            ForEach(sections) { section in
                Section {
                    ForEach(section.items) { item in
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { expandedIDs.contains(item.id) },
                                set: { isExpanding in
                                    if isExpanding {
                                        expandedIDs.insert(item.id)
                                    } else {
                                        expandedIDs.remove(item.id)
                                    }
                                }
                            )
                        ) {
                            Text(item.answer)
                                .font(AppFont.inter(.regular, size: 14))
                                .foregroundStyle(.textGrey)
                                .padding(.top, 4)
                        } label: {
                            Text(item.question)
                                .font(AppFont.inter(.regular, size: 16))
                                .foregroundStyle(.textBlack)
                        }
                        .tint(.textHighlight) 
                    }
                } header: {
                    Text(section.title)
                        .font(AppFont.inter(.regular, size: 14))
                        .foregroundStyle(.textGrey)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Settings")
                    }
                    .font(AppFont.inter(.medium, size: 14))
                    .foregroundStyle(.textHighlight)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("FAQs")
                    .font(AppFont.inter(.bold, size: 16))
            }
        }
    }
}
