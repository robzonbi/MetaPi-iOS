//
//  AlertManager.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-07-13.
//

import SwiftUI

class AlertManager: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var iconName: String = "warning_icon"
    @Published var message: String = "Action Performed"

    func show(icon: String, message: String, duration: TimeInterval = 2.3) {
        self.iconName = icon
        self.message = message
        withAnimation {
            self.isShowing = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                self.isShowing = false
            }
        }
    }
}
