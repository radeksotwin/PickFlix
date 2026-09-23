//
//  PickFlixMainContaierViewModel.swift
//  PickFlix
//
//  Created by Rdm on 17/07/2026.
//
import SwiftUI
import Combine

@MainActor
final class PickFlixMainContaierViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .welcomeToPickFlix
    @Published var selectedMovie: Movie?

    let engine: MoviePickEngineProtocol

    init(engine: MoviePickEngineProtocol = MoviePickEngine()) {
        self.engine = engine
    }

    func startSearch() {
        currentScreen = .searchForMovie
    }

    func showMovie(_ movie: Movie) {
        selectedMovie = movie
        currentScreen = .movieResult
    }

    func pickAnother() {
        selectedMovie = nil
        currentScreen = .searchForMovie
    }

    func goToWelcome() {
        selectedMovie = nil
        currentScreen = .welcomeToPickFlix
    }
}
