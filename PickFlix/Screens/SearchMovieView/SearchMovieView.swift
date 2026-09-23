//
//  SearchMovieView.swift
//  PickFlix
//
//  Created by Rdm on 14/04/2026.
//

import SwiftUI

struct SearchMovieView: View {
    let onMovieFound: (Movie) -> Void

    @StateObject private var viewModel: SearchMovieViewModel
    @State private var pulse = false

    init(engine: MoviePickEngineProtocol, onMovieFound: @escaping (Movie) -> Void) {
        self.onMovieFound = onMovieFound
        _viewModel = StateObject(wrappedValue: SearchMovieViewModel(engine: engine))
    }

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .searching:
                VStack(spacing: 20) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 45))
                        .foregroundStyle(.white)
                        .scaleEffect(pulse ? 1.15 : 0.9)
                        .animation(
                            .easeInOut(duration: 0.7).repeatForever(autoreverses: true),
                            value: pulse
                        )

                    Text("Szukam Twojego filmu…")
                        .font(.headline)
                        .foregroundStyle(.gray)
                }
                .transition(.opacity)

            case .error(let message):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundStyle(.red.opacity(0.8))

                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Button("Spróbuj ponownie") {
                        viewModel.findMovie(onFound: onMovieFound)
                    }
                    .font(.headline)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(AppColors.cardBackground)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.state.isError)
        .onAppear {
            pulse = true
            viewModel.findMovie(onFound: onMovieFound)
        }
    }
}

private extension SearchMovieViewModel.State {
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
}

#Preview {
    SearchMovieView(engine: MockMoviePickEngine(), onMovieFound: { _ in })
        .background(AppColors.primaryBackground)
}
