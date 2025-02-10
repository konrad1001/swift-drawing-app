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
    @Environment(DataManager.self) var dataManager

    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: Image?

    @State private var title: String = "Untitled"

    var isProgressable: Bool {
        return title.count > 0 && selectedImage != nil
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Custom")
                    .font(.title)

                Spacer()

                Button {
                    navigationManager.isUploadedPresented = false

                } label: {
                    Image(systemName: "xmark")
                }
            }

            Group {
                if let image = selectedImage {
                    image
                        .resizable()
                        .scaledToFit()
                } else {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        RoundedRectangle(cornerRadius: 16.0)
                            .fill(.black)
                            .opacity(0.4)
                            .overlay {
                                VStack {
                                    Image(systemName: "plus")
                                    Text("Add")
                                }
                            }
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
                Text("Choose your own photo to use as a reference")
                    .padding(.horizontal, 48)
                    .multilineTextAlignment(.center)
                Spacer()
            }


            Spacer()

            HStack {
                Spacer()

                Button {
                    Task {
                        try await createCustomAsset()
                    }
                } label: {
                    Image(systemName: "paintbrush")
                        .font(.system(size: 24))
                        .padding()
                        .foregroundStyle(isProgressable ? .white : .gray)
                }
            }
            .padding(.vertical)
        }
        .onChange(of: pickerItem) {
            Task {
                selectedImage = try await pickerItem?.loadTransferable(type: Image.self)
            }
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
            try dataManager.createCustomArtwork(newCustom)

            navigationManager.isUploadedPresented = false
            navigationManager.navigateOnto(page: .editor(asset: newCustom.asset, colours: Array(repeating: Color.black, count: 7)))
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
            .environment(NavigationManager())

    } catch {
        fatalError("failed to create preview model")
    }
}
