//
//  BatchMetadataEditView.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-08-01.
//

import SwiftUICore
import SwiftUI


struct BatchMetadataEditView: View {
    @ObservedObject var viewModel: BatchMetadataEditViewModel
    let onSave: () -> Void
    let onCancel: () -> Void
    @State private var showLocationPicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MetadataActionBarView(viewModel: viewModel)

                ZStack {
                    Color("backgroundGreen")
                    Text("Editing metadata for \(viewModel.photoCount) \(viewModel.photoCount == 1 ? "photo" : "photos")")
                        .font(AppFont.inter(.regular, size: 14))
                        .foregroundStyle(.textGreen)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                metadataScrollContent
            }
            .onAppear {
                Task { await viewModel.loadLocationText() }
            }
            .onChange(of: coordinateKey) {
                Task { await viewModel.loadLocationText() }
            }
            .navigationTitle("Edit Metadata")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .fullScreenCover(isPresented: $showLocationPicker) {
                LocationPickerView(initialCoordinate: viewModel.coordinate) { newCoord in
                    viewModel.coordinate = newCoord
                }
            }
        }
    }

    private var metadataScrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                datePickerRow("Date Taken:", date: $viewModel.dateTaken)
                locationSection

                if viewModel.selectedFilter == .all || viewModel.selectedFilter == .iptc {
                    metadataSection(title: "IPTC Metadata", fields: $viewModel.iptcFields)
                }
                if viewModel.selectedFilter == .all || viewModel.selectedFilter == .exif {
                    metadataSection(title: "EXIF Metadata", fields: $viewModel.exifFields)
                }
                if viewModel.selectedFilter == .pi3d {
                    if viewModel.selectedFilter == .pi3d {
                        metadataSection(title: "Pi3D Metadata", fields: pi3dSection)
                    }
                }
            }
            .padding()
            .padding(.bottom, 40)
        }
        .background(.backgroundGrey)
    }

    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { onCancel() }
                    .font(AppFont.inter(.medium, size: 16))
                    .foregroundStyle(.textHighlight.opacity(0.7))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    viewModel.saveChanges()
                    onSave()
                }
                .font(AppFont.inter(.medium, size: 16))
                .foregroundStyle(.textHighlight)
            }
        }
    }

    private func datePickerRow(_ label: String, date: Binding<Date>) -> some View {
        HStack {
            Text(label).font(AppFont.inter(.regular, size: 14))
            Spacer()
            DatePicker("", selection: date, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(AppFont.inter(.regular, size: 13))
                .foregroundStyle(.textHighlight)

            if let coordinate = viewModel.coordinate {
                Text(viewModel.locationText)
                    .font(AppFont.inter(.regular, size: 16))
                    .foregroundStyle(.textBlack)

                PreviewMap(coordinate: coordinate, onTap: {})
                    .frame(height: 160)

                HStack {
                    AppButton(title: "Edit Location",
                              action: { showLocationPicker = true },
                              style: .secondary,
                              fullWidth: true)

                    AppButton(title: "Remove Location",
                              action: { viewModel.removeLocation() },
                              style: .destructive,
                              fullWidth: true)
                }
                .padding(.top, 4)

            } else if viewModel.didRemoveLocation {
                Text("Location removed from all selected photos")
                    .font(AppFont.inter(.regular, size: 16))
                    .foregroundStyle(.textBlack)

                AppButton(title: "Set Location",
                          action: { showLocationPicker = true },
                          fullWidth: true)

            } else {
                HStack {
                    AppButton(title: "Edit Location",
                              action: { showLocationPicker = true },
                              style: .secondary,
                              fullWidth: true)

                    AppButton(title: "Remove Location",
                              action: { viewModel.removeLocation() },
                              style: .destructive,
                              fullWidth: true)
                }
            }
        }
    }

    private func metadataSection(title: String, fields: Binding<[EditableMetadataField]>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(AppFont.inter(.bold, size: 16))

            VStack(spacing: 16) {
                ForEach(fields) { $field in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(field.label)
                                .font(AppFont.inter(.regular, size: 13))
                                .foregroundStyle(.secondary)

                            Button {
                                viewModel.activeInfoLabel = field.label
                                viewModel.showInfoAlert = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                                    .foregroundStyle(.primaryBlue)
                            }
                            .buttonStyle(.plain)
                        }

                        TextField("", text: $field.value)
                            .font(AppFont.inter(.regular, size: 14))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 6)
                            .background(.backgroundWhite)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .alert(isPresented: $viewModel.showInfoAlert) {
            Alert(
                title: Text(viewModel.activeInfoLabel),
                message: Text(viewModel.activeInfoMessage),  
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var pi3dSection: Binding<[EditableMetadataField]> {
        Binding(
            get: {
                viewModel.iptcFields.filter {
                    $0.key == kCGImagePropertyIPTCObjectName as String ||
                    $0.key == kCGImagePropertyIPTCKeywords as String ||
                    $0.key == kCGImagePropertyIPTCCaptionAbstract as String
                }
            },
            set: { newSubset in
                for field in newSubset {
                    if let index = viewModel.iptcFields.firstIndex(where: { $0.key == field.key }) {
                        viewModel.iptcFields[index].value = field.value
                        viewModel.iptcFields[index].isModified = true
                    }
                }
            }
        )
    }

    private var coordinateKey: String {
        viewModel.coordinate.map { "\($0.latitude),\($0.longitude)" } ?? "nil"
    }
}
