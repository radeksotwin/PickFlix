//
//  PickFlixMainContainerView.swift
//  PickFlix
//
//  Created by Rdm on 17/07/2026.
//
import SwiftUI

struct PickFlixAppContainerView: View {
    @StateObject var viewModel = PickFlixMainContaierViewModel()

    var body: some View {
        ZStack {
            GradientBackgroundView()

            switch viewModel.currentScreen {
            case .welcomeToPickFlix:
                WelcomeScreenView()
                    .transition(
                        .opacity
                            .combined(
                                with: .scale(scale:0.96)
                            )
                    )
            case .searchForMovie:
                SearchMovieView()
                    .transition(
                        .opacity
                            .combined(
                                with:
                                        .scale(scale:1.04)
                            )
                    )
                
            }
        }
        
        .animation(
            .spring(
                duration:0.55,
                bounce:0.15
            ),
            value: viewModel.currentScreen
        )
    }
    
    private func startTransition() {
        withAnimation(
            .spring(
                duration:0.45,
                bounce:0.1
            )
        ){
            viewModel.transition = true
        }
        
        
        DispatchQueue.main.asyncAfter(
            deadline:.now()+0.35
        ){
            withAnimation {
                viewModel.currentScreen = .searchForMovie
            }
        }
    }
}

#Preview {
   PickFlixAppContainerView()
}
