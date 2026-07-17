//
//  PickFlixMainContaierViewModel.swift
//  PickFlix
//
//  Created by Rdm on 17/07/2026.
//
import SwiftUI
import Combine

@MainActor
final class PickFlixMainContaierViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .welcomeToPickFlix
    @Published var transition = false
    
}
