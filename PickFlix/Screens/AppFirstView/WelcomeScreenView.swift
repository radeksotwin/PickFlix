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
                WelcomeScreenBackgroundView(isDarkAppearance: isNight)
                
                VStack {
                    Spacer()
                    
                    Label("PickFlix", systemImage: "film")
                        .font(.custom("Avenir", fixedSize: 42))
                        .fontWeight(.heavy)
                        .foregroundColor(isNight ? .black : .white)
                    
                    Spacer()
                    
                    Button(action: {
                        appPath.append(AppScreen.resultView)
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Get started!")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.fromHEX("#FF3B30"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    .padding(20)
                    
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
