//
//  ContentView.swift
//  PickFlix
//
//  Created by Rdm on 26/03/2026.
//

import SwiftUI
import SwiftData

// To future refactor:
// - Wrap animations to a PhaseAnimator object to get consistent behavior of UI for the whole app

struct WelcomeScreenView: View {
    @StateObject var viewModel = WelcomeScreenViewModel()

    var body: some View {
        ZStack {
            // FOR DEBUG
            // Color.blue.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                if viewModel.firstTextVisible {
                    Text("Still scrolling?")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .transition(.opacity)
                    
                }
                
                if viewModel.secondTextVisible {
                    Text("Let's fix that.")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .transition(.opacity)
                }
                
                if viewModel.logoVisible {
                    VStack(spacing: 12) {
                        Label("PickFlix", systemImage: "film")
                            .font(.custom("Avenir Next", fixedSize: 47))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                    }
                    .foregroundStyle(.white)
                    .transition(
                        .scale(scale: 2.7)
                        .combined(with: .opacity)
                    )
                    .scaleEffect(viewModel.isTransitioning ? 0.92 : 1)
                    .opacity(viewModel.isTransitioning ? 0 : 1)
                    .blur(radius: viewModel.isTransitioning ? 6 : 0)
                    .animation(
                        .spring(duration: 0.45),
                        value: viewModel.isTransitioning
                    )
                }
                
                if viewModel.subtitleVisible {
                    VStack(spacing: 4) {
                        Text("One movie.")
                        Text("One decision.")
                    }
                    .font(.headline)
                    .foregroundStyle(.gray)
                    .padding(.top, 24)
                    .transition(.opacity)
                    .opacity(viewModel.isTransitioning ? 0 : 1)
                    .offset(y: viewModel.isTransitioning ? -15 : 0)
                    .animation(
                        .easeOut(duration: 0.35)
                        .delay(0.05),
                        value: viewModel.isTransitioning
                    )
                }
                
                Spacer()
                
                if viewModel.buttonVisible {
                    StartSearchButton(action: {
                        startMovieSearch()
                    })
                    .padding(.bottom, 80)
                    .opacity(viewModel.isTransitioning ? 0 : 1)
                    .scaleEffect(viewModel.isTransitioning ? 0.85 : 1)
                }
            }
        }
        
        .onTapGesture {
            if viewModel.logoVisible {
                viewModel.hideContent()
            } else {
                viewModel.startAnimation()
            }
        }
        
        .onAppear() {
            viewModel.startAnimation()
        }
    }
    
    private func startMovieSearch() {
        withAnimation(
            .spring(
                duration: 0.45,
                bounce: 0.12
            )
        ) {
            viewModel.isTransitioning = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
         
        }
    }
}

#Preview {
    WelcomeScreenView()
        .modelContainer(for: Item.self, inMemory: true)
}
