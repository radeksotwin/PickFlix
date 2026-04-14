//
//  ContentView.swift
//  PickFlix
//
//  Created by Rdm on 26/03/2026.
//

import SwiftUI
import SwiftData

// Set remote for git repository

struct BackgroundView: View {
    var isDarkAppearance: Bool
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [isDarkAppearance ? .black : .gray,
                                                   isDarkAppearance ? .yellow : .black]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
        .ignoresSafeArea()
    }
}

struct AppFirstView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    ///
    ///
    ///
    @State var isNight = false
    
    var body: some View {
        ZStack {
            BackgroundView(isDarkAppearance: isNight) // Check how the binding works

            VStack {
                Spacer()
                
                Label("PickFlix", systemImage: "film")
                    .font(.custom("Avenir", fixedSize: 42))
                    .fontWeight(.heavy)
                    .foregroundColor(isNight ? .black : .white)
                    
                Spacer().frame(height: 350)
                
                Button(action: {
                    isNight.toggle()
                }, label: {
                    Label("Toggle Darkmode!", systemImage: "togglepower")
                        .foregroundColor(isNight ? .black : .white)
                        .font(.custom("", fixedSize: 13))
                })
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    AppFirstView()
        .modelContainer(for: Item.self, inMemory: true)
}
