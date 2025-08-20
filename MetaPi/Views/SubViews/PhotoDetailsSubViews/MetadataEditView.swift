//
//  MetadataEditView.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-06-26.
//

import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct MetadataEditView: View {
    @StateObject private var viewModel: MetadataEditViewModel
    let onSave: () -> Void
    let onCancel: () -> Void
    let onChangesMade: () -> Void
    @State private var showLocationPicker = false
    
    init(imageItem: ImageItem, onSave: @escaping () -> Void, onCancel: @escaping () -> Void, onChangesMade: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: MetadataEditViewModel(photoMetadata: imageItem.metadata))
        self.onSave = onSave
        self.onCancel = onCancel
        self.onChangesMade = onChangesMade
    }

    var body: some View {
        MetadataEditContentView(
            viewModel: viewModel,
            onSave: onSave,
            onCancel: onCancel,
            onChangesMade: onChangesMade

        )
    }
}

private struct MetadataEditContentView: View {
    @ObservedObject var viewModel: MetadataEditViewModel
    let onSave: () -> Void
    let onCancel: () -> Void
    let onChangesMade: () -> Void

    @State private var showLocationPicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MetadataActionBarView(viewModel: viewModel)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        datePickerRow("Date Taken:", date: $viewModel.dateTaken)

                        LocationSectionView(
                            coordinate: $viewModel.coordinate,
                            locationText: viewModel.locationText,
                            onEdit: { showLocationPicker = true },
                            onRemove: { viewModel.removeLocation() }
                        )

                        if viewModel.selectedFilter == .all || viewModel.selectedFilter == .iptc {
                            MetadataSectionView(title: "IPTC Metadata", fields: $viewModel.iptcFields, viewModel: viewModel)
                        }

                        if viewModel.selectedFilter == .all || viewModel.selectedFilter == .exif {
                            MetadataSectionView(title: "EXIF Metadata", fields: $viewModel.exifFields, viewModel: viewModel)
                        }

                        if viewModel.selectedFilter == .pi3d {
                            MetadataSectionView(title: "Pi3D Metadata", fields: pi3dFieldsBinding, viewModel: viewModel)
                        }
                    }
                    .padding()
                    .padding(.bottom, 40)
                }
                .background(.backgroundGrey)
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
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
                    .fontWeight(.semibold)
                }
            }
            .fullScreenCover(isPresented: $showLocationPicker) {
                LocationPickerView(initialCoordinate: viewModel.coordinate) { newCoord in
                    viewModel.coordinate = newCoord
                }
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

    private var coordinateKey: String {
        if let coord = viewModel.coordinate {
            return "\(coord.latitude),\(coord.longitude)"
        } else {
            return "nil"
        }
    }

    private var pi3dFieldsBinding: Binding<[EditableMetadataField]> {
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
                    }
                }
            }
        )
    }
}



private struct MetadataSectionView: View {
    let title: String
    @Binding var fields: [EditableMetadataField]
    @ObservedObject var viewModel: MetadataEditViewModel

    private let numericKeys: Set<String> = [
        kCGImagePropertyExifFocalLength as String,
        kCGImagePropertyExifFocalLenIn35mmFilm as String,
        kCGImagePropertyExifFNumber as String,
        kCGImagePropertyExifISOSpeedRatings as String,
        kCGImagePropertyExifDigitalZoomRatio as String,
        kCGImagePropertyExifExposureBiasValue as String,
        kCGImagePropertyExifExposureTime as String
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(AppFont.inter(.bold, size: 16))

            VStack(spacing: 16) {
                ForEach($fields) { $field in
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
                            .keyboardType(
                                numericKeys.contains(field.key) ? .decimalPad : .default
                            )
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
}


private struct LocationSectionView: View {
    @Binding var coordinate: CLLocationCoordinate2D?
    var locationText: String
    var onEdit: () -> Void
    var onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(AppFont.inter(.regular, size: 13))
                .foregroundStyle(.textHighlight)

            if let coordinate = coordinate {
                Text(locationText)
                    .font(AppFont.inter(.regular, size: 16))
                    .foregroundStyle(.textBlack)

                PreviewMap(coordinate: coordinate, onTap: {})
                    .frame(height: 160)

                HStack {
                    AppButton(title: "Edit Location", action: onEdit, style: .secondary, fullWidth: true)
                    AppButton(title: "Remove Location", action: onRemove, style: .destructive, fullWidth: true)
                }
                .padding(.top, 4)
            } else {
                Text("No location set")
                    .font(AppFont.inter(.regular, size: 16))
                    .foregroundStyle(.textBlack)

                AppButton(title: "Set Location", action: onEdit, fullWidth: true)
            }
        }
    }
}
