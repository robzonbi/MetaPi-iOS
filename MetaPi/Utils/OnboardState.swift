//
//  OnboardState.swift
//  MetaPi
//
//  Created by Yuhang Zhou on 2025-07-14.
//

import Foundation

class OnboardState: ObservableObject {
    @Published var hasSeenOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
        }
    }

    init() {
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
}
