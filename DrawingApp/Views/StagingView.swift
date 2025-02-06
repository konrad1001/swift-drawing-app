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
    @Environment(NavigationManager.self) var navigationManager

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

    var selectedDrawing: Drawing? {
        if case let .editing(drawing) = dataManager.editingState {
            return drawing
        } else {
            return nil
        }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 16) {
                // Nav toolbar
                HStack {
                    Button {
                        navigationManager.navigateBack()
                    } label: {
                        Image(systemName: "chevron.left")
                    }

                    Spacer()
                }
                .font(.title3)
                .foregroundStyle(.white)

                // Focused drawing
                Group {
                    if case let .editing(drawing) = dataManager.editingState, drawing.tag == artwork.assetTag {
                        imageView(for: drawing)
                    } else {
                        RoundedRectangle(cornerRadius: 16.0)
                            .fill(.black.opacity(0.4))
                    }
                }
                .padding(.horizontal, 32)
                .frame(height: proxy.size.height * (1/4))

                // Buttons
                ButtonPanelView()
                    .padding(.bottom, 32)


                // Drawing history
                VStack(alignment: .leading) {
                    Text("History")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Group {
                        if previousDrawings.count == 0 {
                            VStack(spacing: 8) {
                                Spacer()
                                Image(systemName: "clock")
                                HStack {
                                    Spacer()
                                    Text("No saved drawings of ")
                                    Spacer()
                                }
                                Text(artwork.title).underline() + Text(" found.")
                                Spacer()
                            }
                            .font(.title3)
                            .foregroundStyle(.gray)
                        } else {
                            ScrollView(.horizontal) {
                                HStack(spacing: 8) {
                                    ForEach(previousDrawings) { drawing in
                                        imageView(for: drawing)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(.blue, lineWidth: selectedDrawing == drawing ? 5 : 0)
                                            )
                                            .onTapGesture {
                                                dataManager.selectDrawing(drawing)
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: proxy.size.height * (1/4))
                    .padding(.horizontal, -16)
                    .contentMargins(.horizontal, 16)
                    .scrollIndicators(.hidden)
                }
            }
            .padding(.vertical, 64)
            .padding(.horizontal, 16)
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

    @ViewBuilder
    func imageView(for drawing: Drawing) -> some View {
        if let size = canvasManager.canvasSize, let image = drawing.toImage(size: size) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Text("Empty")
                .foregroundStyle(.white)
        }
    }
}

struct ButtonPanelView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(CanvasManager.self) var canvasManager

    @State var userDidSave = false

    var isEnabled: Bool {
        if case .editing = dataManager.editingState { return true }
        return false
    }

    var body: some View {
        HStack {
            iconButton(systemName: userDidSave ? "checkmark.circle.fill" :  "square.and.arrow.down") {
                guard case let .editing(drawing) = dataManager.editingState,
                        let size = canvasManager.canvasSize,
                        let image = drawing.toImage(size: size) else {
                    return
                }
                userDidSave = true

                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }

            iconButton(systemName: "trash") {
                guard case let .editing(drawing) = dataManager.editingState else  {
                    return
                }

                try? dataManager.deleteDrawing(drawing)
            }
        }
        .foregroundStyle(isEnabled ? .white : .gray)
    }

    func iconButton(systemName: String, bold: Bool = true, _ action: @escaping () -> Void) -> some View {
        Button(action: action)  {
            Image(systemName: systemName)
                .font(bold ? .title3.bold() : .title3)
                .padding(12)
        }
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
            .environment(NavigationManager())
    } catch {
        fatalError("failed to create preview model")
    }
}


