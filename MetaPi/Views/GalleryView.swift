//
//  GalleryView.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-22.
//

import SwiftUI
import PhotosUI

struct GalleryView: View {
    @Binding var selectedImage: ImageItem?
    
    @StateObject private var viewModel = GalleryViewModel()
    @State private var reloadID = UUID()
    @State private var isShowingDeleteDialog = false
    @State private var isShowingShareSheet = false
    @StateObject private var alertManager = AlertManager()
    @State private var showBatchMetadataEdit = false
    @State private var batchEditSelection: [ImageItem] = []
    @State private var batchEditViewModel: BatchMetadataEditViewModel?
    
    @State private var showSaveSuccessDialog = false
    @State private var showSaveErrorDialog = false
    @State private var saveSuccessMessage = ""
    @State private var saveErrorMessage = ""
    @State private var showBatchMetadataSuccessDialog = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TopToolbar(
                    isSelecting: viewModel.isSelecting,
                    iconName: "add_icon",
                    action: { viewModel.showPhotoPicker = true },
                    onDone: { viewModel.toggleSelectingMode() }
                )
                .photosPicker(
                    isPresented: $viewModel.showPhotoPicker,
                    selection: $viewModel.selectedPickerItems,
                    maxSelectionCount: 12,
                    matching: .images
                )
                .onChange(of: viewModel.selectedPickerItems) { _, _ in
                    Task { await viewModel.handlePickerSelection() }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.images.isEmpty {
                    EmptyGalleryView { viewModel.showPhotoPicker = true }
                } else {
                    GalleryActionBar(viewModel: viewModel)
                    
                    ImageGridView(
                        images: viewModel.images,
                        imagesPerRow: viewModel.imagesPerRow,
                        isSelecting: viewModel.isSelecting,
                        selectedIDs: viewModel.selectedImageIDs,
                        onImageTap: { item in
                            if viewModel.isSelecting {
                                viewModel.toggleSelection(for: item)
                            } else {
                                selectedImage = item
                            }
                        },
                        showTotalCount: true,
                        totalCount: viewModel.images.count
                    )
                    
                    if viewModel.isSelecting {
                        SelectionActionBar(
                            selectedCount: viewModel.selectedImageIDs.count,
                            onDelete: {
                                guard ensureSelectionExists() else { return }
                                isShowingDeleteDialog = true
                            },
                            onShare: {
                                guard ensureSelectionExists() else { return }
                                isShowingShareSheet = true
                            },
                            onSave: {
                                guard ensureSelectionExists() else { return }
                                Task {
                                    let result = await viewModel.saveSelectedImagesToLibrary()
                                    await MainActor.run {
                                        if result.failed == 0 {
                                            saveSuccessMessage = "\(result.saved) photo\(result.saved == 1 ? "" : "s") saved to phone"
                                            showSaveSuccessDialog = true
                                        } else {
                                            saveErrorMessage = "\(result.failed) failed to save."
                                            showSaveErrorDialog = true
                                        }
                                    }
                                }
                            },
                            onEdit: {
                                let selected = viewModel.images.filter { viewModel.selectedImageIDs.contains($0.id) }
                                guard validateBatchSelection(selected.count) else { return }
                                
                                let metadatas = selected.map { $0.metadata }
                                batchEditViewModel = BatchMetadataEditViewModel(photoMetadatas: metadatas)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showBatchMetadataEdit = true
                                }
                            }
                        )
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: viewModel.isSelecting)
                    }
                }
            }
            .customDialog(
                title: "Metadata updated for \(batchEditViewModel?.photoCount ?? 0) photo\(batchEditViewModel?.photoCount == 1 ? "" : "s")",
                isPresented: $showBatchMetadataSuccessDialog,
                icon: "checkmark_outline_icon",
                dismiss: 2.0
            )
            .customDialog(
                title: saveSuccessMessage,
                isPresented: $showSaveSuccessDialog,
                icon: "save_icon",
                dismiss: 2.0
            )
            .customDialog(
                title: saveErrorMessage,
                isPresented: $showSaveErrorDialog,
                icon: "warning_icon",
                dismiss: 3.0
            )
            .customDialog(
                title: "Your photo will be deleted.\n Are you sure?",
                isPresented: $isShowingDeleteDialog,
                icon: "warning_icon"
            ) {
                HStack(spacing: 8) {
                    AppButton(
                        title: "Delete",
                        action: {
                            viewModel.deleteSelectedImages()
                            isShowingDeleteDialog = false
                        },
                        style: .destructive,
                        fullWidth: true
                    )
                    AppButton(
                        title: "Cancel",
                        action: { isShowingDeleteDialog = false },
                        style: .secondary,
                        fullWidth: true
                    )
                }
            } message: {
                Text("It only deletes the photo in this app.")
            }
            
            if viewModel.isShowingSortMenu {
                VStack {
                    HStack {
                        Spacer()
                        GalleryActionBarDropDown(
                            selectedOption: $viewModel.preferences.selectedSortOption,
                            onOptionSelected: { selected in
                                viewModel.preferences.selectedSortOption = selected
                                viewModel.sortImages()
                                viewModel.isShowingSortMenu = false
                            }
                        )
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 80)
                    
                    Spacer()
                }
                .transition(.opacity)
                .animation(.easeInOut, value: viewModel.isShowingSortMenu)
                .background(
                    Color.black.opacity(0.1)
                        .ignoresSafeArea(edges: .all)
                        .onTapGesture { viewModel.isShowingSortMenu = false }
                )
            }
            
            if alertManager.isShowing {
                HStack(spacing: 8) {
                    Image(alertManager.iconName)
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                    
                    Text(alertManager.message)
                        .font(.callout)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.black.opacity(0.9))
                .cornerRadius(12)
                .padding(.horizontal, 32)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .onChange(of: batchEditViewModel != nil) {
            // Don't remove these or the batch editing will break
        }
        .onChange(of: showBatchMetadataEdit) {
            // Don't remove these or the batch editing will break
        }
        .task(id: reloadID) {
            withAnimation { viewModel.loadImages() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundGrey)
        .toolbar(viewModel.isSelecting ? .hidden : .visible, for: .tabBar)
        .sheet(isPresented: $isShowingShareSheet) {
            ShareSheet(activityItems: viewModel.urlsForSelectedImages())
        }
        .fullScreenCover(isPresented: $showBatchMetadataEdit) {
            if let vm = batchEditViewModel {
                BatchMetadataEditView(
                    viewModel: vm,
                    onSave: {
                        showBatchMetadataEdit = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showBatchMetadataSuccessDialog = true
                        }
                    },
                    onCancel: { showBatchMetadataEdit = false }
                )
            } else {
                VStack {
                    ProgressView("Loading Metadata Editor…")
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.backgroundGrey)
            }
        }
    }
}

private extension GalleryView {
    func ensureSelectionExists() -> Bool {
        if viewModel.selectedImageIDs.isEmpty {
            alertManager.show(
                icon: "warning_icon",
                message: "No photos selected"
            )
            return false
        }
        return true
    }
    
    func validateBatchSelection(_ count: Int) -> Bool {
        if count == 0 {
            alertManager.show(
                icon: "warning_icon",
                message: "No photos selected"
            )
            return false
        }
        if count > 12 {
            alertManager.show(
                icon: "warning_icon",
                message: "Batch metadata editing is limited to 12 photos"
            )
            return false
        }
        return true
    }
}
