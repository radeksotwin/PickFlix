//
//  WelcomeScreenBackgroundView.swift
//  PickFlix
//
//  Created by Rdm on 16/07/2026.
//

import SwiftUI

struct WelcomeScreenBackgroundView: View {
    @State private var animate = false
    
    var body: some View {
        LinearGradient(gradient:
                        Gradient(colors: [animate ? .gray : .black,
                                          animate ? .black : .gray]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
        .onAppear() {
            withAnimation(
                .easeInOut(duration: 2.7)
                .repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
        .ignoresSafeArea()
    }
}
