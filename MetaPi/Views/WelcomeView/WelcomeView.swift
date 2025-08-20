//
//  WelcomeView.swift
//  MetaPi
//
//  Created by Yuhang Zhou on 2025-07-11.
//

import SwiftUI

struct WelcomeView: View {
    @State private var currentPage = 0
    
    let carouselData = [
        CarouselUnit(illustration: "illustration_crop", title: "Crop Tool", text: "Fine-tune your photos — crop to focus, rotate for the right angle, and flip for a new perspective"),
        CarouselUnit(illustration: "illustration_metadata", title: "Edit Metadata", text: "View and edit EXIF, IPTC, and GPS metadata easily — stay in control of your photo details"),
        CarouselUnit(illustration: "illustration_share", title: "Share Anywhere", text: "Send your photos directly to cloud storage apps in just a tap"),
    ]
    
    var onNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.backgroundWhite.ignoresSafeArea() //background set up
            
            VStack {
                VStack(spacing: 16) {
                    Text("Welcome to MetaPi")
                        .font(AppFont.inter(.bold, size: 32))
                        .multilineTextAlignment(.center)
                    
                    Text("Your all-in-one tool to prepare photos for digital frames with ease")
                        .font(AppFont.inter(.regular, size: 16))
                        .multilineTextAlignment(.center)
                        .frame(width: 300)
                }
                .padding(24)
                .foregroundStyle(.textBlack)
                
                TabView(selection: $currentPage) {
                    ForEach(carouselData.indices, id: \.self) { index in
                        let item = carouselData[index]
                        CarouselView(
                            illustration: item.illustration,
                            title: item.title,
                            text: item.text
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 400)
                
                PageControl(
                    numberOfPages: carouselData.count,
                    currentPage: $currentPage,
                )
                .frame(height: 4)
                .padding(.bottom, 32)
                
                VStack {
                    AppButton(
                        title: "Next",
                        action: { onNext() },
                        style: .primary,
                        fullWidth: true
                    )
                }
                .padding(.horizontal, 32)
            }
        }
    }
}


#Preview {
    WelcomeView(onNext: {})
}
