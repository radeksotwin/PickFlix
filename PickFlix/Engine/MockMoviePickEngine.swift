//
//  MockMoviePickEngine.swift
//  PickFlix
//
//  Used in SwiftUI Previews and unit tests.
//

import Foundation

final class MockMoviePickEngine: MoviePickEngineProtocol {
    var result: Result<Movie, Error> = .success(
        Movie(
            title: "Scarface",
            overview: "The world is yours. A story of crime, power, and inevitable fall in Miami.",
            posterURL: "",
            platforms: ["Netflix", "HBO Max"]
        )
    )

    func pickMovie() async throws -> Movie {
        try result.get()
    }
}
