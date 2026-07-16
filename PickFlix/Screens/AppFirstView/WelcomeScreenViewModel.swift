//
//  AppFristViewViewModel.swift
//  PickFlix
//
//  Created by Rdm on 14/04/2026.
//

import SwiftUI
import Combine

class WelcomeScreenViewModel: ObservableObject {
    @Published var shouldNavigateToMovieRecommendationResultView = false
}
