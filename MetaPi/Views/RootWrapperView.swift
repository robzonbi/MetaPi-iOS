//
//  RootWrapperView.swift
//  MetaPi
//
//  Created by Yuhang Zhou on 2025-07-16.
//

import SwiftUI

struct RootWrapperView: View {
    @StateObject private var onboardState = OnboardState()
    
    var body: some View {
        ZStack {
            Color.backgroundWhite.ignoresSafeArea() //background set up
            
            if onboardState.hasSeenOnboarding {
                BottomNavView()
                    .environmentObject(onboardState)
                    .transition(.blurReplace)
            } else {
                OnboardingFlowView()
                    .environmentObject(onboardState)
                    .transition(.blurReplace)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: onboardState.hasSeenOnboarding)
    }
}

#Preview {
    RootWrapperView()
}
