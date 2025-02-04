//
//  DetailsView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/31/25.
//

import SwiftUI
import SwiftData
import PencilKit

struct StagingView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(CanvasManager.self) var canvasManager

    let artwork: Artwork

    var mostRecentDrawing: Drawing? {
        if true {
            return dataManager.drawings.filter { $0.tag == artwork.assetTag }.first
        } else {
            return Drawing(tag: "a")
        }
    }

    var previousDrawings: [Drawing] {
        if true {
            return dataManager.drawings.filter { $0.tag == artwork.assetTag }
        } else {
            return [Drawing(tag: "a"), Drawing(tag: "a"), Drawing(tag: "a")]
        }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                RoundedRectangle(cornerRadius: 16.0)
                    .fill(.black.opacity(0.4))
                    .padding(.horizontal, 32)

                ScrollView(.horizontal) {
                    HStack {
                        ForEach(previousDrawings) { drawing in
                            if let image = canvasManager.toImage(drawing: drawing) {
                                Image(uiImage: image)
                            } else {
                                Text("No image")
                            }
                        }
                    }
                }

            }
            .padding(.vertical, 64)
            .padding()
        }
        .background(
            ZStack {
                Color.black
                Image(artwork.assetTag)
                    .resizable()
                    .saturation(0.6)
                    .scaledToFill()
                    .blur(radius: 20)
                    .opacity(0.4)
            }
        )
        .ignoresSafeArea()
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Drawing.self, configurations: config)

        return StagingView(artwork: Artwork.example)
            .modelContainer(container)
            .environment(DataManager(modelContext: container.mainContext))
            .environment(CanvasManager())

    } catch {
        fatalError("failed to create preview model")
    }
}


