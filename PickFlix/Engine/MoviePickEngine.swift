//
//  MoviePickEngine.swift
//  PickFlix
//

import Foundation

protocol MoviePickEngineProtocol: Sendable {
    func pickMovie() async throws -> Movie
}

final class MoviePickEngine: MoviePickEngineProtocol, Sendable {
    private let tmdb: TMDbServiceProtocol
    private let watchmode: WatchmodeServiceProtocol

    init(
        tmdb: TMDbServiceProtocol = TMDbService(),
        watchmode: WatchmodeServiceProtocol = WatchmodeService()
    ) {
        self.tmdb = tmdb
        self.watchmode = watchmode
    }

    func pickMovie() async throws -> Movie {
        let randomPage = Int.random(in: 1...100)
        let response = try await tmdb.discoverMovies(page: randomPage)

        guard let tmdbMovie = response.results.randomElement() else {
            throw MoviePickError.noMoviesFound
        }

        // Watchmode is best-effort — don't fail the whole pick if it's unavailable
        let platforms = (try? await watchmode.getSources(tmdbId: tmdbMovie.id)) ?? []

        return Movie(
            title: tmdbMovie.title,
            overview: tmdbMovie.overview,
            posterURL: tmdbMovie.posterURL,
            platforms: platforms
        )
    }

    enum MoviePickError: LocalizedError {
        case noMoviesFound
        var errorDescription: String? { "Brak filmów w odpowiedzi API." }
    }
}
