//
//  BottomNavView.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-22.
//

import SwiftUI

enum Tab {
    case gallery, settings
}

struct BottomNavView: View {
    @State private var selectedTab: Tab = .gallery
    @State private var selectedImage: ImageItem?
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                GalleryView(selectedImage: $selectedImage)
                    .tabItem {
                        Image(selectedTab == .gallery ? "gallery_icon_filled" : "gallery_icon")
                        Text("Gallery")
                    }
                    .tag(Tab.gallery)
                
                SettingsView()
                    .tabItem {
                        Image(selectedTab == .settings ? "settings_icon_filled" : "settings_icon")
                        Text("Settings")
                    }
                    .tag(Tab.settings)
            }
            .navigationDestination(item: $selectedImage) { image in
                PhotoDetailsView(
                    imageItem: image,
                    onDeleted: {
                        selectedImage = nil
                    },
                    onPhotoChanged: {}
                )
            }
            .tint(.primaryBlue)
        }
    }
}
