//
//  ContentView.swift
//  PickFlix
//
//  Created by Rdm on 26/03/2026.
//

import SwiftUI
import SwiftData

struct WelcomeScreenView: View {
    @State var isNight = false
    @StateObject var viewModel = WelcomeScreenViewModel()
    @State private var appPath = NavigationPath()
 
    var body: some View {
        NavigationStack(path: $appPath) {
            ZStack {
                WelcomeScreenBackgroundView()
   
                VStack {
                    Spacer()
                    
                    if viewModel.firstTextVisible {
                        Text("Still scrolling?")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                            .transition(.opacity)
                        
                    }
                    
                    if viewModel.secondTextVisible {
                        Text("Let's fix that.")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                            .transition(.opacity)
                    }
                    
                    if viewModel.logoVisible {
                        VStack(spacing: 12) {
                            Label("PickFlix", systemImage: "film")
                                .font(.custom("Avenir Next", fixedSize: 47))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                        }
                        .foregroundStyle(.white)
                        .transition(
                            .scale(scale: 2.7)
                            .combined(with: .opacity)
                        )
                    }
                    
                    if viewModel.subtitleVisible {
                        VStack(spacing: 4) {
                            Text("One movie.")
                            Text("One decision.")
                        }
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .padding(.top, 24)
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    
                    if viewModel.buttonVisible {
                        StartSearchButton(action: {
                            appPath.append(AppScreen.resultView)
                        })
                        .padding(.bottom, 80)
                    }
                }
            }
            
            .onTapGesture {
                if viewModel.logoVisible {
                    viewModel.hideContent()
                } else {
                    viewModel.startAnimation()
                }
            }
            
            .navigationDestination(for: AppScreen.self,
                                   destination: { screen in
                switch screen {
                case .resultView:
                    MovieResultView()
                case .welcomeScreenView:
                    self
                }
            })
        }
    }
}

#Preview {
    WelcomeScreenView()
        .modelContainer(for: Item.self, inMemory: true)
}
