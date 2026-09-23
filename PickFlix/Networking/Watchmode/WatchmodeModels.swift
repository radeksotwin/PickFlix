//
//  WatchmodeModels.swift
//  PickFlix
//

import Foundation

struct WatchmodeSearchResponse: Decodable {
    let titleResults: [WatchmodeTitle]

    enum CodingKeys: String, CodingKey {
        case titleResults = "title_results"
    }
}

struct WatchmodeTitle: Decodable {
    let id: Int
    let name: String
}

struct WatchmodeTitleDetails: Decodable {
    let sources: [WatchmodeSource]?
}

struct WatchmodeSource: Decodable {
    let name: String
    let type: String  // "sub", "rent", "buy", "free"
}
