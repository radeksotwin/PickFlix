//
//  APIClient.swift
//  PickFlix
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:         return "Nieprawidłowy URL."
        case .invalidResponse:    return "Nieprawidłowa odpowiedź serwera."
        case .httpError(let code): return "Błąd HTTP \(code)."
        case .decodingError(let e): return "Błąd dekodowania: \(e.localizedDescription)"
        }
    }
}

struct APIClient {
    static func get<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
