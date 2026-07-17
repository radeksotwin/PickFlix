//
//  MovieResultView.swift
//  PickFlix
//
//  Created by Rdm on 14/04/2026.
//

import SwiftUI

struct SearchMovieView: View {
    static let sampleMovie = Movie(title: "Scarface",
                            overview: "The story about The story abou The story about The story about The story about The story about",
                                   posterURL: "https://www.sdkskds.com",
                                   platforms: ["Netflix, HBO GO, Filmweb"])
    
    /// ---
    
    let movie = Movie(title: "Scarface",
                      overview: "The story about The story abou The story about The story about The story about The story about",
                      posterURL: "https://www.sdkskds.com",
                      platforms: ["Netflix, HBO GO, Filmweb"])
    var onWatch: (() -> Void)? = {}
    var onAnother: (() -> Void)? = {}
    var onSave: (() -> Void)? = {}
    
    @State private var searching = true
    @State private var showMovie = false
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 28) {
                if searching {
                    VStack(spacing:20) {
                        
                        Image(systemName:"sparkles")
                            .font(.system(size:45))
                            .foregroundStyle(.white)
                            .scaleEffect(
                                pulse ? 1.15 : 0.9
                            )
                        
                        Text("Finding your movie")
                            .font(.headline)
                            .foregroundStyle(.gray)
                        
                    }
                    .transition(.opacity)
                }
                
                if showMovie {
                    
                }
            }
        }
        
        .onAppear {
            searchAnotherMovie()
        }
    }
    
    private func searchAnotherMovie() {
        withAnimation(
            .easeInOut(duration:0.7)
        ){
            pulse = true
        }
        
        DispatchQueue.main.asyncAfter(
            deadline:.now()+1.3
        ){
            
            withAnimation(
                .spring(
                    duration:0.7,
                    bounce:0.25
                )
            ){
                searching = false
                showMovie = true
            }
        }
    }
}

#Preview {
    SearchMovieView()
}
