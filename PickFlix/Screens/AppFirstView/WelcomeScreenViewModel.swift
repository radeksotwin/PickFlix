//
//  AppFristViewViewModel.swift
//  PickFlix
//
//  Created by Rdm on 14/04/2026.
//

import SwiftUI
import Combine

@MainActor
final class WelcomeScreenViewModel: ObservableObject {
    @Published var isTransitioning = false
    @Published var firstTextVisible = false
    @Published var secondTextVisible = false
    @Published var logoVisible = false
    @Published var subtitleVisible = false
    @Published var buttonVisible = false

    func startAnimation() {
        Task {
            try? await Task.sleep(for: .milliseconds(250))

            withAnimation(.easeOut(duration: 0.47)) {
                firstTextVisible = true
            }

            try? await Task.sleep(for: .seconds(1.3))

            withAnimation(.easeInOut(duration: 0.3)) {
                firstTextVisible = false
            }

            try? await Task.sleep(for: .milliseconds(200))

            withAnimation(.easeOut(duration: 0.6)) {
                secondTextVisible = true
            }

            try? await Task.sleep(for: .seconds(1.2))

            withAnimation(.easeInOut(duration: 0.4)) {
                secondTextVisible = false
            }

            try? await Task.sleep(for: .milliseconds(150))

            withAnimation(.spring(duration: 0.87)) {
                logoVisible = true
            }

            try? await Task.sleep(for: .milliseconds(180))

            withAnimation(.easeOut(duration: 0.5)) {
                subtitleVisible = true
            }

            try? await Task.sleep(for: .milliseconds(420))

            withAnimation(.spring(response: 0.5,
                                  dampingFraction: 0.77)) {
                buttonVisible = true
            }
        }
    }
    
    func hideContent() {
        firstTextVisible = false
        secondTextVisible = false
        logoVisible = false
        subtitleVisible = false
        buttonVisible = false
        isTransitioning = false
    }
}
