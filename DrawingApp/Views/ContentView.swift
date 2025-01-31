//
//  ContentView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/21/25.
//


import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(DataManager.self) var dataManager

    var body: some View {
        @Bindable var navigationManager = navigationManager

        NavigationStack(path: $navigationManager.path) {
            GeometryReader { geometryProxy in
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(dataManager.artworks) { artwork in
                                FullScreenView(artwork: artwork, proxy: geometryProxy)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0)
                                            .blur(radius: phase.isIdentity ? 0 : 10)
                                    }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                }
            }
            .navigationDestination(for: Page.self) { page in
                CanvasPageView(artwork: page.artwork, colours: page.colours)
            }
            .background(.black)
        }
    }
}

struct FullScreenView: View {
    @Environment(NavigationManager.self) var navigationManager

    let artwork: Artwork
    let proxy: GeometryProxy

    @State var colours: [Color] = []

    @State var isLoading = true

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Image(artwork.assetTag)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16.0))
                    .padding(.vertical, 24)
                    .shadow(radius: 4)
                    .onTapGesture {
                        navigationManager.navigateOnto(page: Page(artwork: artwork, colours: colours))
                    }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(artwork.title)
                            .font(.title.bold())
                        Spacer()
                    }

                    Text(artwork.description)
                        .padding(.bottom, 32)

                    Label {
                        Text(artwork.tooltip)
                    } icon: {
                        Image(systemName: "info.circle")
                    }
                    .foregroundStyle(.gray)
                    .padding(.bottom, 32)

                    HStack {
                        ForEach(0..<6) { index in
                            Rectangle()
                                .fill(colours.count == 6 ? colours[index] : .black)
                                .opacity(isLoading ? 0 : 1)
                                .frame(width: 24, height: 24)
                                .transition(.opacity)
                        }
                        .animation(.default, value: colours)

                        Spacer()
                        Button {
                            navigationManager.navigateOnto(page: Page(artwork: artwork, colours: colours))
                        } label: {
                            HStack {
                                Image(systemName: "paintbrush")
                                    .font(.system(size: 24))
                                    .padding()
                                    .foregroundStyle(isLoading ? .gray : .white)
                            }
                        }
                        .opacity(isLoading ? 0.3 : 1)
                        .disabled(isLoading)
                    }
                    .padding(.trailing)
                }
                .foregroundStyle(.white)

                Spacer()
            }
            .padding()
            .background(
                Image(artwork.assetTag)
                    .resizable()
                    .saturation(0.6)
                    .scaledToFill()
                    .blur(radius: 20)
                    .opacity(0.6)
            )
            .frame(minHeight: proxy.size.height + 40)
        }
        .onAppear {
            Task {
                let colours = await DataManager.fetchPopulousColours(for: artwork)
                self.colours = colours
                print("loaded \(colours) for \(artwork.title)")
                isLoading = false
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Drawing.self, configurations: config)

        return ContentView()
            .modelContainer(container)
            .environment(DataManager(modelContext: container.mainContext))
            .environment(CanvasManager())

    } catch {
        fatalError("failed to create preview model")
    }
}
