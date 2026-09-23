//
//  TMDbModels.swift
//  PickFlix
//

import Foundation

struct TMDbDiscoverResponse: Decodable {
    let page: Int
    let results: [TMDbMovie]
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}

struct TMDbMovie: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
    }

    var posterURL: String {
        guard let path = posterPath else { return "" }
        return "https://image.tmdb.org/t/p/w500\(path)"
    }
}
