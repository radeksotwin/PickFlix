//
//  WelcomeScreenBackgroundView.swift
//  PickFlix
//
//  Created by Rdm on 16/07/2026.
//

import SwiftUI

struct WelcomeScreenBackgroundView: View {
    var isDarkAppearance: Bool
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [isDarkAppearance ? .black : .gray,
                                                   isDarkAppearance ? .yellow : .black]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
        .ignoresSafeArea()
    }
}
