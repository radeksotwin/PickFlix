//
//  MovieResultViewModel.swift
//  PickFlix
//

import Foundation

final class MovieResultViewModel {
    let movie: Movie
    let onAnother: () -> Void

    init(movie: Movie, onAnother: @escaping () -> Void) {
        self.movie = movie
        self.onAnother = onAnother
    }
}
