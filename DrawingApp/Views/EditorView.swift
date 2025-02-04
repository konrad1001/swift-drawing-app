//
//  EditorView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/23/25.
//

import PencilKit
import SwiftData
import SwiftUI

struct EditorView: View {
    @Environment(CanvasManager.self) var canvasManager
    @Environment(DataManager.self) var dataManager
    @Environment(NavigationManager.self) var navigationManager

    let artwork: Artwork
    let colours: [Color]

    var mostRecentDrawing: Drawing? {
        if true {
            return dataManager.drawings.filter { $0.tag == artwork.assetTag }.first
        } else {
            return Drawing(tag: "a")
        }
    }

    init(artwork: Artwork, colours: [Color]) {
        assert(colours.count == 7)
        self.artwork = artwork
        self.colours = colours
    }

    var body: some View {
        GeometryReader { geometryProxy in
            VStack(alignment: .leading, spacing: 16) {
                // Nav toolbar
                HStack {
                    Button {
                        navigationManager.navigateBack()
                    } label: {
                        Image(systemName: "chevron.left")
                    }

                    Spacer()

                    Button {
                        navigationManager.navigateOnto(page: .stage(artwork: artwork))
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                .font(.title3)
                .foregroundStyle(.white)

                // Reference
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

                    PalatteView(colours)
                }

                .frame(height: geometryProxy.size.height * (1/3))

                // Canvas
                if let mostRecentDrawing {
                    VStack {
                        CanvasView(drawing: mostRecentDrawing)
                            .frame(height: geometryProxy.size.width * (4/5))
                    }
                    .padding(.horizontal, -16)
                    .overlay {
                        GeometryReader { canvasSizeProxy in
                            Color.clear
                                .onAppear {
                                    canvasManager.canvasSize = canvasSizeProxy.size
                                }
                        }
                    }
                } else {
                    Button(action: {
                        try? dataManager.createNewDrawing(forTag: artwork.assetTag)
                    }, label: {
                        VStack(spacing: 8) {
                            Spacer()
                            Image(systemName: "plus")
                            HStack {
                                Spacer()
                                Text("New")
                                Spacer()
                            }

                            Spacer()
                        }
                        .font(.title3)
                        .foregroundStyle(.white)
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
            .padding(.top, 52)
            .toolbar(.hidden)
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

        return EditorView(artwork: Artwork.example, colours: [.gray,.orange,.yellow,.green,.blue,.indigo])
            .modelContainer(container)
            .environment(DataManager(modelContext: container.mainContext))
            .environment(CanvasManager())
            .environment(NavigationManager())

    } catch {
        fatalError("failed to create preview model")
    }
}
