//
//  AppConfig.swift
//  PickFlix
//

import Foundation

enum AppConfig {
    static let tmdbAPIKey: String =
        Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String
            ?? "799dfb6672bb4dd7dd3f8eead44cb4ff"

    static let watchmodeAPIKey: String =
        Bundle.main.object(forInfoDictionaryKey: "WATCHMODE_API_KEY") as? String
            ?? "gEZQXbKsruJFhgUmrG8QdX3RvpBHXCU0QXzZxF0s"
}
