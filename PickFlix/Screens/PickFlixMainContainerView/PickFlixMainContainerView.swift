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
                WelcomeScreenView(onStartSearch: viewModel.startSearch)
                    .transition(
                        .opacity.combined(with: .scale(scale: 0.96))
                    )

            case .searchForMovie:
                SearchMovieView(
                    engine: viewModel.engine,
                    onMovieFound: viewModel.showMovie
                )
                .transition(
                    .opacity.combined(with: .scale(scale: 1.04))
                )

            case .movieResult:
                if let movie = viewModel.selectedMovie {
                    MovieResultView(
                        movie: movie,
                        onAnother: viewModel.pickAnother,
                        onWatch: viewModel.goToWelcome
                    )
                    .transition(
                        .opacity.combined(with: .scale(scale: 1.04))
                    )
                }
            }
        }
        .animation(
            .spring(duration: 0.55, bounce: 0.15),
            value: viewModel.currentScreen
        )
    }
}

#Preview {
    PickFlixAppContainerView()
}
