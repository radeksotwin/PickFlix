//
//  PickFlixApp.swift
//  PickFlix
//
//  Created by Rdm on 26/03/2026.
//

import SwiftUI
import SwiftData

@main
struct PickFlixApp: App {
    
    /// ------------
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    /// ------------
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
