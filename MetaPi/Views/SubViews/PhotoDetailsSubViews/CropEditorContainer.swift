//
//  CropEditorContainer.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-08-07.
//
import SwiftUI

struct CropEditorContainer: View {
    let image: UIImage
    let imageItem: ImageItem
    let onCropped: (UIImage) -> Void
    let onCancel: () -> Void
    @Binding var showSuccessDialog: Bool
    let onChangesMade: () -> Void


    var body: some View {
        ZStack {
            Color("backgroundDarkGrey").ignoresSafeArea()
            CropEditorView(
                image: image,
                imageItem: imageItem,
                onCropped: onCropped,
                onCancel: onCancel,
                showSuccessDialog: $showSuccessDialog,
                onChangesMade: onChangesMade
            )
        }
        .preferredColorScheme(.dark)
    }
}

