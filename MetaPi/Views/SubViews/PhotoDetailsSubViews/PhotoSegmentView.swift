//
//  PhotoSegmentView.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-06-23.
//
import SwiftUI
import MapKit

struct PhotoSegmentView: View {
    @ObservedObject var viewModel: PhotoDetailsViewModel
    @Binding var shouldReload: Bool

    @State private var reloadID = UUID()
    @State private var showingMapOverlay = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal)
                } else {
                    Text("Failed to load image.")
                        .foregroundStyle(.gray)
                        .padding()
                }

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name")
                            .font(AppFont.inter(.regular, size: 12))
                            .foregroundStyle(.textHighlight)
                        Text(viewModel.imageName)
                            .font(AppFont.inter(.medium, size: 14))
                            .foregroundStyle(.textBlack)
                    }

                    HStack(spacing: 24) {
                        InfoColumn(label: "Resolution", value: viewModel.resolution)
                        InfoColumn(label: "Size", value: viewModel.fileSize)
                        InfoColumn(label: "Type", value: viewModel.fileType)
                    }

                    HStack(spacing: 24) {
                        InfoColumn(label: "Date", value: viewModel.photoDate)
                        InfoColumn(label: "Time", value: viewModel.photoTime)
                        InfoColumn(label: "Device", value: viewModel.deviceModel)
                    }
                }
                .padding(.horizontal)

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Location")
                        .font(AppFont.inter(.regular, size: 12))
                        .foregroundStyle(.textHighlight)
                    Text(viewModel.locationText)
                        .font(AppFont.inter(.regular, size: 16))
                        .foregroundStyle(.textBlack)

                    if let coordinate = viewModel.locationCoordinate {
                        PreviewMap(coordinate: coordinate) {
                            showingMapOverlay = true
                        }
                        .frame(height: 160)
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
        }
        .id(reloadID)
        .task(id: reloadID) {
            if shouldReload {
                await viewModel.reload()
                shouldReload = false
            }
        }
        .sheet(isPresented: $showingMapOverlay) {
            if let coordinate = viewModel.locationCoordinate {
                MapOverlay(
                    coordinate: coordinate,
                    locationText: viewModel.locationText,
                    isPresented: $showingMapOverlay
                )
            }
        }
    }
}
