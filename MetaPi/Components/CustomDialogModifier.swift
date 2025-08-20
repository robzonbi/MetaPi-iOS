//
//  CustomDialogModifier.swift
//  MetaPi
//
//  Created by Yuhang Zhou on 2025-07-21.
//

import SwiftUI

struct CustomDialogModifier<Actions: View, Message: View>: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let icon: String?
    let actions: Actions?
    let message: Message?
    let dismiss: TimeInterval?
    
    @State private var dismissTimer: Timer?
    @State private var isAnimating = false
    
    init(
        title: String,
        isPresented: Binding<Bool>,
        icon: String? = nil,
        @ViewBuilder actions: () -> Actions? = { nil },
        @ViewBuilder message: () -> Message? = { EmptyView() },
        dismiss: TimeInterval? = nil
    ) {
        self._isPresented = isPresented
        self.title = title
        self.icon = icon
        self.actions = actions()
        self.message = message()
        self.dismiss = dismiss
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isAnimating)
                
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        if let icon {
                            Image(icon)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.primaryBlue)
                        }
                        
                        Text(title)
                            .font(AppFont.inter(.regular, size: 16))
                            .foregroundStyle(.textBlack)
                            .multilineTextAlignment(.center)
                        
                        if let message {
                            message
                                .multilineTextAlignment(.center)
                                .font(AppFont.inter(.regular, size: 14))
                                .foregroundStyle(.textHighlight)
                        }
                    }
                    
                    if let actions {
                        actions
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                .frame(width: 300)
                .frame(minHeight: 200)
                .background(.backgroundWhite)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 10)
                .offset(y: isAnimating ? 0 : 50)
                .opacity(isAnimating ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isAnimating)
            }
        }
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                isAnimating = true
                setupAutoDismiss()
            } else {
                isAnimating = false
                cancelAutoDismiss()
            }
        }
        .onDisappear {
            cancelAutoDismiss()
        }
    }
    
    private func setupAutoDismiss() {
        guard let duration = dismiss else { return }
        
        cancelAutoDismiss()
        dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isAnimating = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isPresented = false
            }
        }
    }
    
    private func cancelAutoDismiss() {
        dismissTimer?.invalidate()
        dismissTimer = nil
    }
}

extension View {
    // Overload for dialogs without actions
    func customDialog<Message: View>(
        title: String,
        isPresented: Binding<Bool>,
        icon: String? = nil,
        @ViewBuilder message: @escaping () -> Message? = { EmptyView() },
        dismiss: TimeInterval? = nil
    ) -> some View {
        modifier(CustomDialogModifier<EmptyView, Message>(
            title: title,
            isPresented: isPresented,
            icon: icon,
            actions: { EmptyView() as EmptyView? },
            message: message,
            dismiss: dismiss
        ))
    }
    
    // Overload for dialogs with actions
    func customDialog<Actions: View, Message: View>(
        title: String,
        isPresented: Binding<Bool>,
        icon: String? = nil,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder message: @escaping () -> Message? = { EmptyView() },
        dismiss: TimeInterval? = nil
    ) -> some View {
        modifier(CustomDialogModifier(
            title: title,
            isPresented: isPresented,
            icon: icon,
            actions: { actions() },
            message: message,
            dismiss: dismiss
        ))
    }
}
