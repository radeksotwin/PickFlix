//
//  MovieResultView.swift
//  PickFlix
//
//  Created by Rdm on 14/04/2026.
//

import SwiftUI

struct MovieResultView: View {
    static let sampleMovie = Movie(title: "Scarface",
                            overview: "The story about The story abou The story about The story about The story about The story about",
                            posterURL: "https://www.sdkskds.com",
                            platforms: ["Netflix, HBO GO, Filmweb"])
    
    /// ---
    
    let movie: Movie
    var onWatch: (() -> Void)? = {}
    var onAnother: (() -> Void)? = {}
    var onSave: (() -> Void)? = {}
    
    var body: some View {
        ZStack {
            Color.fromHEX("0B0B0F")
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                // Poster
                AsyncImage(url: URL(string: movie.posterURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 320)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.0),
                            Color.black.opacity(0.8)
                        ],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(20)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Title
                Text(movie.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // Description
                Text(movie.overview)
                    .font(.system(size: 16))
                    .foregroundColor(Color.fromHEX("#A1A1AA"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 24)
                
                // Platforms
                HStack(spacing: 8) {
                    ForEach(movie.platforms, id: \.self) { platform in
                        Text(platform)
                            .font(.system(size: 13, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.fromHEX("#2A2A33"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                // CTA
                Button(action: onWatch!) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Watch now")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.fromHEX("#FF3B30"))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                
                // Secondary actions
                HStack(spacing: 32) {
                    
                    Button(action: onAnother!) {
                        Text("Another one")
                            .foregroundColor(.white)
                    }
                    
                    Button(action: onSave!) {
                        HStack {
                            Image(systemName: "heart")
                            Text("Save")
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 24)
            }
        }
    }
}

#Preview {
    MovieResultView(movie: MovieResultView.sampleMovie)
}
