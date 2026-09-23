//
//  SearchMovieViewModel.swift
//  PickFlix
//

import SwiftUI
import Combine

@MainActor
final class SearchMovieViewModel: ObservableObject {
    enum State {
        case searching
        case error(String)
    }

    @Published var state: State = .searching

    private let engine: MoviePickEngineProtocol

    init(engine: MoviePickEngineProtocol) {
        self.engine = engine
    }

    func findMovie(onFound: @escaping (Movie) -> Void) {
        state = .searching
        Task {
            do {
                let movie = try await engine.pickMovie()
                onFound(movie)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}
