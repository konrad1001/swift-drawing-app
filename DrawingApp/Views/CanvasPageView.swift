//
//  CanvasPageView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/23/25.
//

import PencilKit
import SwiftData
import SwiftUI

struct CanvasPageView: View {
    @Environment(CanvasManager.self) var canvasManager
    @Environment(DataManager.self) var dataManager

    let artwork: Artwork
    let colours: [Color]

    var mostRecentDrawing: Drawing? {
        if true {
            return dataManager.drawings.filter { $0.tag == artwork.assetTag }.first
        } else {
            return Drawing(tag: "a")
        }
    }

    var body: some View {
        GeometryReader { geometryProxy in
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.black.opacity(0.4))
                        ZoomableImage(artwork: artwork)
                    }
                    .frame(height: geometryProxy.size.height * (1/3))
                    .frame(width: geometryProxy.size.width * (3/5))

                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Spacer(minLength: 0)

                    PalatteView(colours: colours)
                }

                .frame(height: geometryProxy.size.height * (1/3))

                if let mostRecentDrawing {
                    VStack {
                        CanvasView(drawing: mostRecentDrawing, bgColour: colours.first)
                            .frame(height: geometryProxy.size.width * (4/5))
                    }
                    .padding(.horizontal, -16)
                } else {
                    Button(action: {
                        try? dataManager.createNewDrawing(forTag: artwork.assetTag)
                    }, label: {
                        VStack {
                            Spacer()
                            Image(systemName: "plus")
                            HStack {
                                Spacer()
                                Text("New")
                                Spacer()
                            }

                            Spacer()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16.0)
                            .fill(.black.opacity(0.4))
                        )
                        .frame(height: geometryProxy.size.width * (4/5))

                    })
                }

                // Toolbar
                ToolbarView()
            }
            .padding(.horizontal)
            .padding(.top, 78)
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

        return CanvasPageView(artwork: Artwork.example, colours: [.gray,.orange,.yellow,.green,.blue,.indigo])
            .modelContainer(container)
            .environment(DataManager(modelContext: container.mainContext))
            .environment(CanvasManager())

    } catch {
        fatalError("failed to create preview model")
    }
}
