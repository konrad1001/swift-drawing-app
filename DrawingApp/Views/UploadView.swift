//
//  UploadView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 2/10/25.
//

import PhotosUI
import SwiftData
import SwiftUI

struct UploadView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(CanvasManager.self) var canvasManager
    @Environment(DataManager.self) var dataManager

    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: Image?

    @State private var title: String = ""
    @State private var isProgressing: Bool = false
    @State private var isLoading: Bool = false

    var isProgressable: Bool {
        return title.count > 0 && selectedImage != nil
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Custom Muse")
                    .font(.title)

                Spacer()

                Button {
                    navigationManager.isUploadedPresented = false

                } label: {
                    Image(systemName: "xmark")
                }
            }

            PhotosPicker(selection: $pickerItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16.0)
                        .fill(.black)
                        .opacity(0.4)
                    VStack {
                        Image(systemName: "plus")
                        Text("Add")
                    }

                    if let image = selectedImage {
                        image
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            .frame(height: 300)
            .padding(.bottom, 64)

            Text("Title")
                .font(.headline)

            TextField("Title", text: $title)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16.0)
                        .fill(.black)
                        .opacity(0.4)
                }
                .padding(.bottom, 64)

            HStack {
                Spacer()
                Text("Choose your own photo to use as a Muse")
                    .padding(.horizontal, 48)
                    .multilineTextAlignment(.center)
                Spacer()
            }

            Spacer()

            HStack {
                Spacer()

                Button {
                    isProgressing = true
                    isLoading = true
                    canvasManager.resetInteractableState(toggleScaleToFit: false)
                    Task {
                        try await createCustomAsset()
                    }
                } label: {
                    Image(systemName: "paintbrush")
                        .font(.system(size: 24))
                        .padding()
                        .foregroundStyle((isProgressable && !isProgressing) ? .white : .gray)
                        .background {
                            Circle()
                                .fill(.clear)
                                .stroke(Gradients.defaultGradient, lineWidth: 5)
                                .blur(radius: isProgressable ? 1 : 10)
                                .opacity(isProgressable ? 0.8 : 0)
                                .opacity(isLoading ? 0.2 : 1)
                                .animation(
                                    Animation.easeInOut(duration: 1)
                                    .repeatForever(autoreverses: true), value: isLoading
                                  )
                                .shadow(radius: 4)
                        }
                        .animation(.default, value: isProgressable)
                        .animation(.default, value: isProgressing)
                }
                .disabled(!isProgressable || isProgressing)
            }
            .padding(.vertical)
        }
        .onChange(of: pickerItem) {
            Task {
                selectedImage = try await pickerItem?.loadTransferable(type: Image.self)
            }
        }
        .onAppear {
            title = "Untitled #\(dataManager.customAssetCount+1)"
        }
        .padding()
        .foregroundStyle(.white)
        .background(
            Image("artist_studio")
                .resizable()
                .saturation(0.6)
                .scaledToFill()
                .blur(radius: 20)
                .opacity(0.6)
        )
        .background(.black)
        .ignoresSafeArea()
    }

    func createCustomAsset() async throws {
        guard let imageData = try await pickerItem?.loadTransferable(type: Data.self),
                !title.isEmpty else {
            return
        }

        let newCustom = CustomArtwork(imageData: imageData, title: title, dateCreated: Date())

        do {
            try dataManager.createCustomAsset(newCustom)

            let colours = await newCustom.asset.fetchPopulousColours()
            let asset = newCustom.asset

            navigationManager.scrollFocusID = asset.id
            navigationManager.isUploadedPresented = false
            navigationManager.navigateOnto(page: .editor(asset: asset, colours: colours))
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Drawing.self, configurations: config)

        return UploadView()
            .modelContainer(container)
            .environment(DataManager(modelContext: container.mainContext))
            .environment(CanvasManager())
            .environment(NavigationManager())

    } catch {
        fatalError("failed to create preview model")
    }
}
