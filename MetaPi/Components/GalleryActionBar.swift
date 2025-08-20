//
//  GalleryActionBar.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-24.
//

import SwiftUI

struct GalleryActionBar<T: GalleryActionBarControlling>: View {
    @ObservedObject var viewModel: T
    
    var body: some View {
        HStack(spacing: 20) {
            Spacer()
            
            if viewModel.isSelecting {
                AppButton (
                    title: viewModel.areAllImagesSelected ? "Deselect All" : "Select All",
                    action: { viewModel.toggleSelectAll() },
                    style: .primary,
                    size: .small)
                
            } else {
                AppButton(
                    title: "Select",
                    action: { viewModel.toggleSelectingMode() },
                    style: .primary,
                    size: .small)
                
                Button(action: {
                    withAnimation {
                        viewModel.zoomOut()
                    }
                }) {
                    Image("zoomOut_icon")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                }
                .disabled(!viewModel.canZoomOut)
                .foregroundStyle(viewModel.canZoomOut ? AnyShapeStyle(.textBlack) : AnyShapeStyle(.textBlack.opacity(0.3)))
                
                
                Button(action: {
                    withAnimation {
                        viewModel.zoomIn()
                    }
                }) {
                    Image("zoomIn_icon")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                }
                .disabled(!viewModel.canZoomIn)
                .foregroundStyle(viewModel.canZoomIn ? AnyShapeStyle(.textBlack) : AnyShapeStyle(.textBlack.opacity(0.3)))
                
                Button(action: {
                    viewModel.isShowingSortMenu.toggle()
                }) {
                    Image("menu_icon")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.primaryBlue)
                }
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 56)
        .background(.backgroundGrey)
    }
}
