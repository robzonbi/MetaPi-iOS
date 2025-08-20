//
//  MetaPiApp.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-21.
//

import SwiftUI


@main
struct MetaPiApp: App {
    @StateObject private var onboardState = OnboardState()
    @StateObject var preferences = UserPreferences.shared
    
    init() {
        TabBarStyle.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootWrapperView()
                .environmentObject(onboardState)
                .environmentObject(preferences)
                .preferredColorScheme(preferences.preferredScheme)
        }
    }
}
