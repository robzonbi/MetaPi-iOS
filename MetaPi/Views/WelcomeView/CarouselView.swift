//
//  CarouselView.swift
//  MetaPi
//
//  Created by Yuhang Zhou on 2025-07-11.
//

import SwiftUI

struct CarouselView: View {
    let illustration: String
    let title: String
    let text: String
    
    var body: some View {
        VStack {
            Image(illustration)
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 240)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(AppFont.inter(.bold, size: 20))
                    .multilineTextAlignment(.center)
                
                Text(text)
                    .font(AppFont.inter(.regular, size: 16))
                    .lineSpacing(6)
                    .multilineTextAlignment(.center)
                    .frame(width: 260)
            }
            .padding()
            .foregroundStyle(.textBlack)
        }
    }
}

#Preview {
    CarouselView(illustration: "illustration_crop", title: "Crop Tool", text: "Fine-tune your photos — crop to focus, rotate for the right angle, and flip for a new perspective")
}
