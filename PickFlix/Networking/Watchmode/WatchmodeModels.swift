//
//  WatchmodeModels.swift
//  PickFlix
//

import Foundation

struct WatchmodeSearchResponse: Decodable, Sendable {
    let titleResults: [WatchmodeTitle]

    enum CodingKeys: String, CodingKey {
        case titleResults = "title_results"
    }
}

struct WatchmodeTitle: Decodable, Sendable {
    let id: Int
    let name: String
}

struct WatchmodeTitleDetails: Decodable, Sendable {
    let sources: [WatchmodeSource]?
}

struct WatchmodeSource: Decodable, Sendable {
    let name: String
    let type: String  // "sub", "rent", "buy", "free"
}
