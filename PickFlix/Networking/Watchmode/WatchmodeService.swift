//
//  WatchmodeService.swift
//  PickFlix
//

import Foundation

protocol WatchmodeServiceProtocol {
    /// Returns subscription platform names for a given TMDb movie ID.
    func getSources(tmdbId: Int) async throws -> [String]
}

final class WatchmodeService: WatchmodeServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.watchmode.com/v1"

    init(apiKey: String = AppConfig.watchmodeAPIKey) {
        self.apiKey = apiKey
    }

    func getSources(tmdbId: Int) async throws -> [String] {
        // Step 1: resolve TMDb ID → Watchmode title ID
        var searchComponents = URLComponents(string: "\(baseURL)/search/")!
        searchComponents.queryItems = [
            .init(name: "apiKey",       value: apiKey),
            .init(name: "search_field", value: "tmdb_movie_id"),
            .init(name: "search_value", value: "\(tmdbId)")
        ]
        guard let searchURL = searchComponents.url else { throw APIError.invalidURL }

        let searchResponse: WatchmodeSearchResponse = try await APIClient.get(searchURL)
        guard let titleId = searchResponse.titleResults.first?.id else { return [] }

        // Step 2: fetch sources
        var detailsComponents = URLComponents(string: "\(baseURL)/title/\(titleId)/details/")!
        detailsComponents.queryItems = [
            .init(name: "apiKey",              value: apiKey),
            .init(name: "append_to_response",  value: "sources")
        ]
        guard let detailsURL = detailsComponents.url else { throw APIError.invalidURL }

        let details: WatchmodeTitleDetails = try await APIClient.get(detailsURL)

        let names = (details.sources ?? [])
            .filter { $0.type == "sub" }
            .map { $0.name }

        return Array(Set(names)).sorted()
    }
}
