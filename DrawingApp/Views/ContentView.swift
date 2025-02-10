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

    @State var scrollFocusId: UUID?

    var focusingHistoricAssets: Bool {
        if scrollFocusId == nil { return true }

        let focusedAsset = dataManager.assets.first { asset in
            asset.id == scrollFocusId
        }

        if case .historic = focusedAsset?.typeContent {
            return true
        }
        return false
    }

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
                                    .id(asset.id)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .animation(.default, value: dataManager.assets)
                    .scrollPosition(id: $scrollFocusId)
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                    .overlay(alignment: .bottom) {
                        HStack(spacing: 16) {
                            Button("Historic") {
                                withAnimation {
                                    scrollFocusId = dataManager.firstHistoric?.id
                                    scrollViewProxy.scrollTo(dataManager.firstHistoric?.id)
                                }
                            }
                            .foregroundStyle(focusingHistoricAssets ? .white : .gray)

                            Button("Custom") {
                                withAnimation {
                                    scrollFocusId = dataManager.firstCustom?.id
                                    scrollViewProxy.scrollTo(dataManager.firstCustom?.id)
                                }
                            }
                            .foregroundStyle(!focusingHistoricAssets ? .white : .gray)


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
