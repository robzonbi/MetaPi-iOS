//
//  OnboardingFlowView.swift
//  MetaPi
//
//  Created by Yuhang Zhou on 2025-07-14.
//

import SwiftUI

struct OnboardingFlowView: View {
    @State private var path: [Screen] = []
    @EnvironmentObject var onboardState: OnboardState
    
    enum Screen: Hashable {
        case privacy
        case home
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView {
                path.append(.privacy)
            }
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .privacy:
                    PrivacyDisclaimerView(
                        onNext: {
                            withAnimation {
                                onboardState.hasSeenOnboarding = true
                                path.append(.home)
                            }
                        },
                        onBack: {
                            path.removeLast() // go back to WelcomeView
                        }
                    )
                case .home:
                    BottomNavView()
                }
            }
        }
    }
}

#Preview {
    OnboardingFlowView()
}
