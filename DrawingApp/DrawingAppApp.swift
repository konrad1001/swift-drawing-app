//
//  DrawingAppApp.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/21/25.
//

import SwiftData
import SwiftUI

@main
struct DrawingAppApp: App {
    let container: ModelContainer
    let dataManager: DataManager

    init() {
        guard let container = try? ModelContainer(for: Drawing.self, CustomArtwork.self),
              let dataManager = DataManager(modelContext: container.mainContext) else {
            fatalError("Data manager could not be initialised")
        }

        self.container = container
        self.dataManager = dataManager
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
//                .preferredColorScheme(.light)
        }
        .environment(NavigationManager())
        .environment(CanvasManager())
        .environment(dataManager)
        .modelContainer(container)
    }
}
