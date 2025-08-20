//
//  PhotoDetails.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-23.
//

import SwiftUI
import MapKit

enum PhotoDetailSegment: String, CaseIterable, Identifiable {
    case photo = "Photo"
    case metadata = "Metadata"
    var id: String { rawValue }
}

struct PhotoDetailsView: View {
    @State private var selectedSegment: PhotoDetailSegment = .photo
    @StateObject private var viewModel: PhotoDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    let onDeleted: () -> Void
    let onPhotoChanged: () -> Void

    @State private var showOptions = false
    @State private var showDeleteAlert = false
    @State private var showSaveAlert = false
    @State private var showRemoveMetadataAlert = false
    @State private var showRemoveMetadataConfirmation = false
    @State private var showMetadataSuccessDialog = false
    @State private var showCropSuccessDialog = false

    @State private var saveSuccessMessage: String?
    @State private var showEditMetadataSheet = false
    @State private var showCropEditor = false
    @State private var showShareSheet = false
    @State private var reloadID = UUID()
    @State private var shouldReload = false

    init(imageItem: ImageItem, onDeleted: @escaping () -> Void, onPhotoChanged: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: PhotoDetailsViewModel(imageItem: imageItem))
        self.onDeleted = onDeleted
        self.onPhotoChanged = onPhotoChanged
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                segmentPicker
                Divider()
                segmentContent
            }
            bottomActions
        }
        .customDialog(title: saveSuccessMessage ?? "", isPresented: $showSaveAlert, icon: "save_icon", dismiss: 2.0)
        .customDialog(title: "Your photo will be deleted.\n Are you sure?", isPresented: $showDeleteAlert, icon: "warning_icon") {
            HStack(spacing: 8) {
                AppButton(title: "Delete", action: {
                    deletePhoto()
                    showDeleteAlert = false
                }, style: .destructive, fullWidth: true)
                AppButton(title: "Cancel", action: {
                    showDeleteAlert = false
                }, style: .secondary, fullWidth: true)
            }
        } message: {
            Text("It only deletes the photo in this app.")
        }
        .customDialog(title: "Remove all metadata from this photo?", isPresented: $showRemoveMetadataAlert, icon: "warning_icon") {
            HStack(spacing: 8) {
                AppButton(title: "Remove", action: {
                    removeMetadata()
                    showRemoveMetadataAlert = false
                    showRemoveMetadataConfirmation = true
                }, style: .destructive, fullWidth: true)
                AppButton(title: "Cancel", action: {
                    showRemoveMetadataAlert = false
                }, style: .secondary, fullWidth: true)
            }
        } message: {
            Text("This will strip all metadata (EXIF, IPTC, GPS, TIFF) from the image.")
        }
        .customDialog(title: "Metadata Removed", isPresented: $showRemoveMetadataConfirmation, icon: "checkmark_outline_icon", dismiss: 2.0)
        .customDialog(title: "Changes Saved", isPresented: $viewModel.showSavedConfirmation, icon: "checkmark_outline_icon", dismiss: 1.5)
        .customDialog(title: "Metadata updated successfully!", isPresented: $showMetadataSuccessDialog, icon: "checkmark_outline_icon", dismiss: 2.0)
        .customDialog(title: "Photo updated successfully!", isPresented: $showCropSuccessDialog, icon: "checkmark_outline_icon", dismiss: 2.0)
        .confirmationDialog("More Options", isPresented: $showOptions) {
            actionDialogContent
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Gallery")
                    }
                    .font(AppFont.inter(.medium, size: 14))
                    .foregroundStyle(.textHighlight)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Photo Details")
                    .font(AppFont.inter(.bold, size: 16))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showOptions = true } label: {
                    Image("menu_icon")
                        .frame(width: 44, height: 44)
                        .foregroundStyle(.primaryBlue)
                }
            }
        }
        .background(.backgroundWhite)
        .task(id: reloadID) { await viewModel.reload() }
        .fullScreenCover(isPresented: $showEditMetadataSheet) { editMetadataSheet }
        .fullScreenCover(isPresented: $showCropEditor) { cropEditorSheet }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [viewModel.imageItem.imageURL])
        }
        .onDisappear {
            // ensure we drop any large buffers when leaving
            viewModel.releaseFullImage()
        }
    }

    private var segmentPicker: some View {
        Picker("", selection: $selectedSegment) {
            ForEach(PhotoDetailSegment.allCases) { segment in
                Text(segment.rawValue).tag(segment)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 224)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private var segmentContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                switch selectedSegment {
                case .photo:
                    PhotoSegmentView(viewModel: viewModel, shouldReload: $shouldReload)
                case .metadata:
                    MetadataSegmentView(
                        viewModel: MetadataSegmentViewModel(metadata: viewModel.metadata),
                        shouldReload: $shouldReload
                    )
                }
            }
            .padding(.bottom, 100)
        }
    }

    private var bottomActions: some View {
        HStack(spacing: 0) {
            actionButton(imageName: "crop_icon_circle", label: "Crop Photo") {
                viewModel.loadFullImageIfNeeded()
                showCropEditor = true
            }

            actionButton(imageName: "edit_icon_circle", label: "Edit Metadata") {
                showEditMetadataSheet = true
            }

            actionButton(imageName: "share_icon_circle", label: "Share Photo") {
                showShareSheet = true
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 8)
        .frame(height: 90)
        .background(.backgroundWhite)
        .overlay(
            Rectangle().frame(height: 1)
                .foregroundStyle(Color.gray.opacity(0.3)),
            alignment: .top
        )
    }

    private func actionButton(imageName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(imageName)
                    .resizable()
                    .frame(width: 44, height: 44)
                Text(label)
                    .font(AppFont.inter(.medium, size: 14))
                    .foregroundStyle(.textBlack)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var actionDialogContent: some View {
        Button("Save to Phone") { saveToPhone() }
        Button("Delete Photo", role: .destructive) { showDeleteAlert = true }
        Button("Remove Metadata", role: .destructive) { showRemoveMetadataAlert = true }
        Button("Cancel", role: .cancel) {}
    }

    @ViewBuilder
    private var editMetadataSheet: some View {
        MetadataEditView(
            imageItem: viewModel.imageItem,
            onSave: {
                showEditMetadataSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    reloadID = UUID()
                    onPhotoChanged()
                    showMetadataSuccessDialog = true
                }
            },
            onCancel: {
                showEditMetadataSheet = false
            },
            onChangesMade: {
                viewModel.showSavedConfirmation = true
            }
        )
    }

    @ViewBuilder
    private var cropEditorSheet: some View {
        CropEditorContainer(
            image: viewModel.editingImage.normalizedImage(),
            imageItem: viewModel.imageItem,
            onCropped: { cropped in
                let upright = cropped.normalizedImage()
                _ = viewModel.imageItem.saveEditedVersion(upright)
                reloadID = UUID()
                onPhotoChanged()
                showCropEditor = false
                viewModel.releaseFullImage()
            },
            onCancel: {
                showCropEditor = false
                viewModel.releaseFullImage()
            },
            showSuccessDialog: $showCropSuccessDialog,
            onChangesMade: {
                viewModel.showSavedConfirmation = true
            }
        )
    }
    private func saveToPhone() {
        Task {
            let result = await viewModel.saveToPhoneLibrary()
            await MainActor.run {
                saveSuccessMessage = result.success
                    ? "Your photo has been saved to your phone!"
                    : (result.error ?? "Unknown error")
                showSaveAlert = true
            }
        }
    }

    private func deletePhoto() {
        Task {
            viewModel.deletePhoto()
            await MainActor.run {
                onDeleted()
                dismiss()
            }
        }
    }

    private func removeMetadata() {
        Task {
            await viewModel.removeAllMetadata()
            await MainActor.run {
                reloadID = UUID()
                onPhotoChanged()
                showRemoveMetadataConfirmation = true
            }
        }
    }
}
