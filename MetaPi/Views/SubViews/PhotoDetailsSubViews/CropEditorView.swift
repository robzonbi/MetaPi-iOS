//
//  CropView.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-07-06.
//

import SwiftUI
import Mantis

struct CropEditorView: UIViewControllerRepresentable {
    let image: UIImage
    let imageItem: ImageItem
    let onCropped: (UIImage) -> Void
    let onCancel: () -> Void
    @Binding var showSuccessDialog: Bool
    let onChangesMade: () -> Void
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let customToolbar = CropCustomToolbar()
        let cropVC = Mantis.cropViewController(
            image: image,
            cropToolbar: customToolbar
        )
        cropVC.delegate = context.coordinator
        context.coordinator.cropViewController = cropVC

        let navController = UINavigationController(rootViewController: cropVC)
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(named: "backgroundDarkGrey")

        navController.navigationBar.standardAppearance = navBarAppearance
        navController.navigationBar.scrollEdgeAppearance = navBarAppearance
        navController.navigationBar.compactAppearance = navBarAppearance
        
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: context.coordinator,
            action: #selector(context.coordinator.didTapCancel)
        )
        cancelButton.setTitleTextAttributes([
            .foregroundColor: UIColor(named: "primaryBlue")?.withAlphaComponent(0.7) ?? UIColor.blue.withAlphaComponent(0.7),
            .font: AppFont.interUIFont(size: 16, weight: .regular)
        ], for: .normal)
        
        let saveButton = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: context.coordinator,
            action: #selector(context.coordinator.didTapDone)
        )
        saveButton.setTitleTextAttributes([
            .foregroundColor: UIColor(named: "primaryBlue") ?? UIColor.blue,
            .font: AppFont.interUIFont(size: 16, weight: .medium)
        ], for: .normal)

        let title = UILabel()
        title.text = "Crop Photo"
        title.font = AppFont.interUIFont(size: 16, weight: .bold)
        title.textColor = UIColor.white

        cropVC.navigationItem.leftBarButtonItem = cancelButton
        cropVC.navigationItem.rightBarButtonItem = saveButton
        cropVC.navigationItem.titleView = title

        return navController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            imageItem: imageItem,
            onCropped: onCropped,
            onCancel: onCancel,
            originalImage: image,
            showSuccessDialog: $showSuccessDialog,
            onChangesMade: onChangesMade

        )
    }
    
    final class Coordinator: NSObject, CropViewControllerDelegate {
        let imageItem: ImageItem
        let onCropped: (UIImage) -> Void
        let onCancel: () -> Void
        let originalImage: UIImage
        @Binding var showSuccessDialog: Bool
        let onChangesMade: () -> Void
        
        var hasChanges: Bool = false
        private let customToolbar = CropCustomToolbar()
        weak var cropViewController: CropViewController?
        
        init(
            imageItem: ImageItem,
            onCropped: @escaping (UIImage) -> Void,
            onCancel: @escaping () -> Void,
            originalImage: UIImage,
            showSuccessDialog: Binding<Bool>,
            onChangesMade: @escaping () -> Void

        ) {
            self.imageItem = imageItem
            self.onCropped = onCropped
            self.onCancel = onCancel
            self.originalImage = originalImage
            self._showSuccessDialog = showSuccessDialog
            self.onChangesMade = onChangesMade

        }
        
        func cropViewControllerDidImageTransformed(_ cropViewController: CropViewController, transformation: Transformation) {
            hasChanges = true
        }
        
        func cropViewControllerDidCrop(
            _ cropViewController: CropViewController,
            cropped: UIImage,
            transformation: Transformation,
            cropInfo: CropInfo
        ) {
            let success = imageItem.saveEditedVersion(cropped)

            if success {
                let now = Date()
                let updatedProps: [String: Any] = [
                    kCGImagePropertyIPTCDictionary as String: [
                        kCGImagePropertyIPTCDigitalCreationDate as String: MetadataFormatter.iptcDateString(from: now),
                        kCGImagePropertyIPTCDigitalCreationTime as String: MetadataFormatter.iptcTimeString(from: now)
                    ]
                ]
                imageItem.metadata.saveMetadata(updatedProperties: updatedProps)

                Task {
                    showSuccessDialog = true
                }

                onCropped(cropped)
                if hasChanges {
                    onChangesMade()
                }
            } else {
                print("Failed to overwrite image on disk")
            }

            cropViewController.dismiss(animated: true)
        }
        
        func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
            onCancel()
            cropViewController.dismiss(animated: true)
        }
        
        func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
            onCancel()
            cropViewController.dismiss(animated: true)
        }
        
        @objc func didTapCancel() {
            guard let cropVC = cropViewController else { return }
            cropViewControllerDidCancel(cropVC, original: originalImage)
        }
        
        @objc func didTapDone() {
            cropViewController?.crop()
        }
    }
}
