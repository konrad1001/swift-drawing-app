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
                            ForEach(dataManager.assets) { asset in
                                FullScreenView(asset: asset, proxy: geometryProxy)
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
                    .overlay(alignment: .bottom) {
                        HStack(spacing: 16) {
                            Button("Historic") {
                                print("historic")
                            }

                            Button("Custom") {
                                print("custom")
                            }

                            Spacer()

                            Button("Upload") {
                                navigationManager.isUploadedPresented = true
                            }
                            .foregroundStyle(navigationManager.isUploadedPresented ? .white : .gray)
                        }
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 64)
                    }
                }
            }
            .navigationDestination(for: Page.self) { page in
                switch page {
                case let .editor(asset: asset, colours: colours):
                    EditorView(asset: asset, colours: colours)
                        .toolbar(.hidden)
                case let .stage(asset: asset):
                    StagingView(asset: asset)
                        .toolbar(.hidden)
                }
            }
            .sheet(isPresented: $navigationManager.isUploadedPresented, content: {
                UploadView()
            })
            .background(.black)
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
            .environment(NavigationManager())

    } catch {
        fatalError("failed to create preview model")
    }
}
