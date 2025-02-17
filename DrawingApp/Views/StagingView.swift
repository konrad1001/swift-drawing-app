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

    let asset: Asset

    var previousDrawings: [Drawing] {
        let filteredDrawings = dataManager.drawings.filter { $0.tag == asset.assetTag}

        return filteredDrawings.sorted(by: { $0.dateCreated > $1.dateCreated })
    }

    var selectedDrawing: Drawing? {
        if case let .editing(drawing) = dataManager.editingState[asset] {
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
                ZStack {
                    RoundedRectangle(cornerRadius: 16.0)
                        .fill(.black.opacity(0.4))
                    if case let .editing(drawing) = dataManager.editingState[asset], drawing.tag == asset.assetTag {
                        imageView(for: drawing)
                    }
                }
                .padding(.horizontal, 32)
                .frame(height: proxy.size.height * (1/4))
                .clipShape(RoundedRectangle(cornerRadius: 16.0))

                // Buttons
                ButtonPanelView(asset: asset)
                    .padding(.bottom, 32)


                // Drawing history
                VStack(alignment: .leading) {
                    HStack {
                        Text("History")
                        Spacer()
                    }
                        .font(.headline)
                        .foregroundStyle(.white)

                    Group {
                        if previousDrawings.count == 0 {
                            VStack(spacing: 8) {
                                Spacer()
                                Image(systemName: "clock")

                                Text("No saved drawings of ") + Text(asset.title).underline() + Text(" found.")

                                Spacer()
                            }
                            .font(.title3)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 48)
                        } else {
                            ScrollView(.horizontal) {
                                HStack(spacing: 8) {
                                    ForEach(previousDrawings) { drawing in
                                        imageView(for: drawing)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Gradients.defaultGradient, lineWidth: selectedDrawing == drawing ? 5 : 0)
                                            )
                                            .onTapGesture {
                                                dataManager.selectDrawing(drawing, forAsset: asset)
                                            }
                                    }
                                }
                                .animation(.easeInOut, value: previousDrawings)
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

    @ViewBuilder
    func imageView(for drawing: Drawing) -> some View {
        if let size = canvasManager.canvasSize, let image = drawing.toImage(size: size) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipped()
        } else {
            EmptyView()
        }
    }
}

struct ButtonPanelView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(CanvasManager.self) var canvasManager

    @State var userDidSave = false
    @State var showDeletionAlert = false

    let asset: Asset

    var isEnabled: Bool {
        if case .editing = dataManager.editingState[asset] { return true }
        return false
    }

    var body: some View {
        HStack {
            iconButton(systemName: userDidSave ? "checkmark.circle.fill" : "square.and.arrow.down") {
                guard case let .editing(drawing) = dataManager.editingState[asset],
                        let size = canvasManager.canvasSize,
                        let image = drawing.toImage(size: size) else {
                    return
                }
                let imageSaver = ImageSaver {
                    Task {
                        userDidSave = true
                        try await Task.sleep(nanoseconds: 1_500_000_000)
                        userDidSave = false
                    }
                }
                imageSaver.saveToCameraRoll(image: image)
            }

            iconButton(systemName: "trash") {
                guard case .editing = dataManager.editingState[asset] else  {
                    return
                }

                showDeletionAlert = true
            }
        }
        .animation(.default, value: userDidSave)
        .foregroundStyle(isEnabled ? .white : .gray)
        .alert("Careful!", isPresented: $showDeletionAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Okay") {
                try? dataManager.clearDrawingForAsset(asset)
            }
        } message: {
            Text("Are you sure you want to delete this drawing?")
        }
    }

    func iconButton(systemName: String, bold: Bool = true, _ action: @escaping () -> Void) -> some View {
        Button(action: action)  {
            Image(systemName: systemName)
                .font(bold ? .title3.bold() : .title3)
                .padding(12)
        }
        .contentTransition(.symbolEffect(.replace))
    }

    class ImageSaver: NSObject {
        var callback: () -> Void

        init(callback: @escaping () -> Void) {
            self.callback = callback
        }

        func saveToCameraRoll(image: UIImage) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
        }

        @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            callback()
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Drawing.self, configurations: config)

        return StagingView(asset: Artwork.example.asset)
            .modelContainer(container)
            .environment(DataManager(modelContext: container.mainContext))
            .environment(CanvasManager())
            .environment(NavigationManager())
    } catch {
        fatalError("failed to create preview model")
    }
}


