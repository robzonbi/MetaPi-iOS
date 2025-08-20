//
//  AboutView.swift
//  MetaPi
//
//  Created by Vinaydeep Singh Padda on 2025-08-01.
//

import SwiftUI

struct AboutView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let aboutText = "MetaPi is designed to simplify photo preparation for digital frame displays—especially DIY setups like the Pi3D picture frame. \n\n With MetaPi, you can crop and adjust image orientation, edit EXIF and IPTC metadata, and seamlessly share your photos to apps like Google Drive or Dropbox and more. \n\nOriginally built for the Pi3D digital frame community, MetaPi is also ideal for anyone who wants full control over photo metadata and how their images are displayed."
    
    private let privacyURL = URL(string: "https://robzonbi.github.io/Privacy_policy")!
    private let termsURL   = URL(string: "https://robzonbi.github.io/Terms_of_use")!
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                VStack(spacing: 8){
                    Image("metapiLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .padding(.top)
                    
                    Text("Version 1.0.0")
                        .font(AppFont.inter(.regular, size: 14))
                        .foregroundStyle(.textGrey)
                }
                
                Text(aboutText)
                    .lineSpacing(2)
                    .font(AppFont.inter(.regular, size: 14))
                    .foregroundStyle(.textBlack)
                    .multilineTextAlignment(.center)
                
                Divider()
                    .background(Color.secondary)
                    .padding(.vertical, 4)
                
                VStack (spacing: 16) {
                    
                    Link(destination: privacyURL) {
                        Text("Privacy Policy")
                            .font(AppFont.inter(.semibold, size: 14))
                            .foregroundStyle(.textHighlight)
                        
                    }
                    
                    Link(destination: termsURL) {
                        Text("Terms of Use")
                            .font(AppFont.inter(.semibold, size: 14))
                            .foregroundStyle(.textHighlight)
                    }
                }
                
                Divider()
                    .background(Color.secondary)
                    .padding(.vertical, 4)
                
                Text("Support: ")
                    .font(AppFont.inter(.regular, size: 14))
                    .foregroundStyle(.textBlack)
                +
                Text("robbieaggas\u{200B}@gmail.com")
                    .font(AppFont.inter(.regular, size: 14))
                    .foregroundStyle(.textBlack)
                
            }
            .padding(24)
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Settings")
                    }
                    .font(AppFont.inter(.medium, size: 14))
                    .foregroundStyle(.textHighlight)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("About")
                    .font(AppFont.inter(.bold, size: 16))
            }
        }
        .background(Color.backgroundGrey.ignoresSafeArea())
        
    }
       
}

