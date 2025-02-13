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

    @State var refreshing = false

    let asset: Asset
    let colours: [Color]

    var focusedDrawing: Drawing? {
        if case let .editing(drawing) = dataManager.editingState[asset], drawing.id == asset.id {
            return drawing
        }
        return nil
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
                        navigationManager.navigateOnto(page: .stage(asset: asset))
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                .font(.title3)
                .foregroundStyle(.white)
                .zIndex(1)

                // Reference
                HStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.black.opacity(0.4))
                        ZoomableImage(asset: asset)
                    }
                    .frame(height: geometryProxy.size.height * (1/3))
                    .frame(width: geometryProxy.size.width * (3/5))

                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Spacer(minLength: 0)

                    PaletteView(asset: asset, colours: colours)
                }
                .frame(height: geometryProxy.size.height * (1/3))

                // Canvas
                Group {
                    switch (dataManager.editingState[asset], refreshing) {
                    case (.editing, true):
                        Spacer()
                    case (.editing(let drawing), false):
                        VStack {
                            UICanvasView(canvasManager: canvasManager, drawing: drawing)
                        }
                        .padding(.horizontal, -16)
                        .onChange(of: drawing) {
                            // Hack to force UIViewRepresentable to update.
                            Task {
                                refreshing = true
                                canvasManager.bgColour = Color(uiColor: drawing.getBgColour())
                                try? await Task.sleep(nanoseconds: 500_000)
                                refreshing = false
                            }
                        }
                        .onAppear {
                            canvasManager.bgColour = Color(drawing.getBgColour())
                        }
                    default:
                        createNewDrawingView(proxy: geometryProxy)
                            .onAppear {
                                canvasManager.bgColour = colours[0]
                                canvasManager.color = colours[1]
                            }
                    }
                }
                .animation(.default, value: refreshing)

                .frame(height: geometryProxy.size.width * (4/5))
                .onAppear {
                    canvasManager.canvasSize = CGSize(width: geometryProxy.size.width, height: geometryProxy.size.width * (4/5))
                }

                // Toolbar
                ToolbarView()
            }
            .padding(.horizontal)
            .padding(.top, 52)
        }
        .background(
            ZStack {
                Color.black
                asset.image
                    .resizable()
                    .saturation(0.6)
                    .scaledToFill()
                    .blur(radius: 20)
                    .opacity(0.4)
            }
        )
        .ignoresSafeArea()
    }

    func createNewDrawingView(proxy: GeometryProxy) -> some View {
        Button(action: {
            try? dataManager.createNewDrawing(forAsset: asset, withBackgroundColour: UIColor(canvasManager.bgColour))
        }, label: {
            VStack(spacing: 8) {
                Spacer()
                Image(systemName: "photo.badge.plus.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                HStack {
                    Spacer()
                    Text("New")
                        .font(.title3)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.bottom, 16)

                Text("Tap on the \(Image(systemName: "line.3.horizontal")) to continue previous drawings.")
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 32)

                Spacer()
            }

            .background(
                RoundedRectangle(cornerRadius: 16.0)
                    .fill(.black.opacity(0.4))
            )
        })
    }
}

#Preview {  
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Drawing.self, configurations: config)

        return EditorView(asset: Artwork.example.asset, colours: Array(repeating: Color.black, count: 7))
            .modelContainer(container)
            .environment(DataManager(modelContext: container.mainContext))
            .environment(CanvasManager())
            .environment(NavigationManager())

    } catch {
        fatalError("failed to create preview model")
    }
}
