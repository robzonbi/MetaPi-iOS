//
//  ImageGridView.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-23.
//

import SwiftUI
import ImageIO
import UIKit


struct ImageGridView: View {
    let images: [ImageItem]
    let imagesPerRow: Int
    let isSelecting: Bool
    let selectedIDs: Set<String>
    let onImageTap: (ImageItem) -> Void
    let showTotalCount: Bool
    let totalCount: Int

    var body: some View {
        let spacing: CGFloat = 2
        let totalSpacing = spacing * CGFloat(imagesPerRow - 1)
        let screenWidth = UIScreen.main.bounds.width - 2
        let itemSide = (screenWidth - totalSpacing) / CGFloat(imagesPerRow)

        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: imagesPerRow),
                spacing: spacing
            ) {
                ForEach(images) { item in
                    ZStack(alignment: .topLeading) {
                        SquareThumbView(url: item.imageURL, side: itemSide)
                            .contentShape(Rectangle())
                            .onTapGesture { onImageTap(item) }
                            .animation(.easeInOut(duration: 0.2), value: images)

                        // Missing location badge (optional)
                        if UserDefaults.standard.bool(forKey: "MissingLocationIndicatorEnabled") {
                            let gps = item.metadata.properties["{GPS}"] as? [String: Any] ?? [:]
                            if gps.isEmpty {
                                Image("missing_location")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding(6)
                            }
                        }

                        // Selection overlay
                        if isSelecting && selectedIDs.contains(item.id) {
                            Color.white.opacity(0.2)
                                .frame(width: itemSide, height: itemSide)
                                .allowsHitTesting(false)

                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    ZStack {
                                        Circle().fill(.white)
                                        Image("checkmark_outline_icon")
                                            .resizable()
                                            .foregroundStyle(.primarySelected)
                                            .frame(width: 20, height: 20)
                                    }
                                    .frame(width: 20, height: 20)
                                    .padding(6)
                                }
                            }
                            .frame(width: itemSide, height: itemSide)
                            .allowsHitTesting(false)
                        }
                    }
                    .frame(width: itemSide, height: itemSide)
                }
            }

            if showTotalCount {
                Text("Photos: \(totalCount)")
                    .font(AppFont.inter(.regular, size: 12))
                    .foregroundStyle(.textGrey)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
            }
        }
    }
}


struct SquareThumbView: View {
    let url: URL
    let side: CGFloat

    @Environment(\.displayScale) private var displayScale
    @State private var image: UIImage?
    @State private var task: Task<Void, Never>?

    var body: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
                    .frame(width: side, height: side)
                    .clipped()
            } else {
                Rectangle()
                    .frame(width: side, height: side)
                    .opacity(0.08)
            }
        }
        .onAppear { load() }
        .onChange(of: side) { _, _ in load() }
        .onDisappear { task?.cancel() }
    }

    private func load() {
        guard side > 0 else { return }
        task?.cancel()
        let target = CGSize(width: side, height: side)

        task = Task {
            let img = await Thumbnailer.shared.image(url: url, size: target, scale: displayScale)
            if Task.isCancelled { return }
            await MainActor.run { self.image = img }
        }
    }
}
