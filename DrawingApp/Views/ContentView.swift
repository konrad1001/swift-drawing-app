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

    var focusingHistoricAssets: Bool {
        if navigationManager.scrollFocusID == nil { return true }

        let focusedAsset = dataManager.assets.first { asset in
            asset.id == navigationManager.scrollFocusID
        }

        if case .historic = focusedAsset?.typeContent { 
            return true
        }
        return false
    }

    var userHasCustomAssets: Bool {
        dataManager.customAssetCount > 0
    }

    let noCustomAssetsDisclaimerID = UUID()
    let homepageID = UUID()

    var body: some View {
        @Bindable var navigationManager = navigationManager

        NavigationStack(path: $navigationManager.path) {
            GeometryReader { geometryProxy in
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        // LazyVStack won't load some images and palettes on iOS 17
                        VStack {
                            if navigationManager.homePageIsActive {
                                HomeView(proxy: geometryProxy)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0)
                                            .blur(radius: phase.isIdentity ? 0 : 20)
                                            .scaleEffect(phase.isIdentity ? 1 : 0.8)
                                    }
                                    .id(homepageID)
                            }

                            ForEach(dataManager.assets) { asset in
                                ZStack {
                                    FullScreenView(asset: asset, proxy: geometryProxy)
                                        .scrollTransition { content, phase in
                                            content
                                                .opacity(phase.isIdentity ? 1 : 0)
                                                .blur(radius: phase.isIdentity ? 0 : 10)
                                        }
                                        .id(asset.id)
                                }
                            }

                            if !userHasCustomAssets {
                                VStack(spacing: 8) {
                                    Spacer()
                                    Image(systemName: "clock")
                                        .foregroundStyle(.white)

                                    Text("You've not uploaded any custom Muses to copy from.")
                                        .foregroundStyle(.white)
                                        .padding(.bottom, 32)

                                    Text("Tap on the upload button to get started.")
                                        .foregroundStyle(.gray)
                                        .shadow(radius: 2)

                                    Spacer()
                                }
                                .id(noCustomAssetsDisclaimerID)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 48)
                                .background(
                                    Image("artist_studio")
                                        .resizable()
                                        .saturation(0.6)
                                        .scaledToFill()
                                        .blur(radius: 20)
                                        .opacity(0.6)
                                )
                                .frame(minHeight: geometryProxy.size.height + 40)
                            }
                        }
                        .scrollTargetLayout()
                    }

                    .animation(.default, value: dataManager.assets)
                    .scrollDisabled(navigationManager.homePageIsActive)
                    .scrollPosition(id: $navigationManager.scrollFocusID)
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                    .sensoryFeedback(.success, trigger: navigationManager.homePageIsActive)
                    .overlay(alignment: .bottom) {
                        HStack(spacing: 16) {
                            HStack {
                                Button("Historic") {
                                    withAnimation {
                                        navigationManager.scrollFocusID = dataManager.firstHistoric?.id
                                        scrollViewProxy.scrollTo(dataManager.firstHistoric?.id)
                                    }
                                }
                                .foregroundStyle(focusingHistoricAssets ? .white : .gray)

                                Text("•")

                                Button("Custom") {
                                    withAnimation {
                                        if userHasCustomAssets {
                                            navigationManager.scrollFocusID = dataManager.firstCustom?.id
                                            scrollViewProxy.scrollTo(dataManager.firstCustom?.id)
                                        } else {
                                            navigationManager.scrollFocusID = noCustomAssetsDisclaimerID
                                            scrollViewProxy.scrollTo(noCustomAssetsDisclaimerID)
                                        }
                                    }
                                }
                                .foregroundStyle(!focusingHistoricAssets ? .white : .gray)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 32.0)
                                    .fill(.black.opacity(0.4))
                                    .blur(radius: 0.2)
                            }

                            Spacer()

                            Button("Upload") {
                                navigationManager.isUploadedPresented = true
                            }
                            .foregroundStyle(navigationManager.isUploadedPresented ? .white : .gray)
                        }
                        .foregroundStyle(.gray)
                        .opacity(navigationManager.homePageIsActive ? 0 : 1)
                        .padding(.horizontal, 48)
                        .padding(.bottom, 16)
                        .animation(.default, value: navigationManager.homePageIsActive)
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
            .environment(CanvasManager())
            .environment(NavigationManager())

    } catch {
        fatalError("failed to create preview model")
    }
}
