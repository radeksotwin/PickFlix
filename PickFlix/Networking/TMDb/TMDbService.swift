//
//  TMDbService.swift
//  PickFlix
//

import Foundation

protocol TMDbServiceProtocol {
    func discoverMovies(page: Int) async throws -> TMDbDiscoverResponse
}

final class TMDbService: TMDbServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.themoviedb.org/3"

    init(apiKey: String = AppConfig.tmdbAPIKey) {
        self.apiKey = apiKey
    }

    func discoverMovies(page: Int) async throws -> TMDbDiscoverResponse {
        var components = URLComponents(string: "\(baseURL)/discover/movie")!
        components.queryItems = [
            .init(name: "api_key",           value: apiKey),
            .init(name: "sort_by",           value: "popularity.desc"),
            .init(name: "vote_count.gte",    value: "200"),
            .init(name: "page",              value: "\(page)")
        ]
        guard let url = components.url else { throw APIError.invalidURL }
        return try await APIClient.get(url)
    }
}
