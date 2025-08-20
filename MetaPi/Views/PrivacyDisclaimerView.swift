//
//  PrivacyDisclaimerView.swift
//  MetaPi
//
//  Created by Yuhang Zhou on 2025-07-13.
//

import SwiftUI

struct PrivacyDisclaimerView: View {
    @State private var navigateToGallery = false
    @State private var navigateToWelcome = false
    
    var onNext: () -> Void
    var onBack: () -> Void
    
    private let privacyURL = URL(string: "https://robzonbi.github.io/Privacy_policy")!
    private let termsURL   = URL(string: "https://robzonbi.github.io/Terms_of_use")!
    
    var body: some View {
        ZStack {
            Color.backgroundWhite.ignoresSafeArea()
            
            VStack {
                VStack(spacing: 16) {
                    Text("Your Privacy Matters")
                        .font(AppFont.inter(.bold, size: 32))
                        .multilineTextAlignment(.center)
                    
                    Text("We do not store, sell, or share your personal data with anyone")
                        .font(AppFont.inter(.regular, size: 16))
                        .multilineTextAlignment(.center)
                        .frame(width: 300)
                        .foregroundStyle(.textBlack)
                }
                .padding(24)
                
                Image("illustration_privacy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                
                VStack(spacing: 16) {
                    Text("To function properly, the app requires a few permissions, but only what's necessary for key features to work")
                        .font(AppFont.inter(.regular, size: 14))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 290)
                    
                    HStack(spacing: 4) {
                        Text("Find more details in our")
                        Link(destination: privacyURL) {
                            Text("Privacy Policy")
                                .underline()
                        }
                    }
                    .font(AppFont.inter(.regular, size: 12))
                    .foregroundStyle(.textHighlight)
                }
                .padding(24)
                
                HStack {
                    Image("warning_icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("By continuing, you agree to our")
                        HStack {
                            Link(destination: privacyURL) {
                                Text("Privacy Policy")
                                    .underline()
                            }
                            Text("and")
                            Link(destination: termsURL) {
                                Text("Terms of Use")
                                    .underline()
                            }
                        }
                        .foregroundStyle(.textHighlight)
                    }
                    .font(AppFont.inter(.regular, size: 12))
                }
                
                VStack {
                    AppButton(
                        title: "Next",
                        action: { onNext() },
                        style: .primary,
                        fullWidth: true
                    )
                    
                    AppButton(
                        title: "Back",
                        action: { onBack() },
                        style: .secondary,
                        fullWidth: true
                    )
                }
                .padding(.top, 24)
                .padding(.horizontal, 32)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}
