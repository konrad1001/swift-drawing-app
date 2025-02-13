//
//  FullScreenView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/28/25.
//

import SwiftUI

struct FullScreenView: View {
    @Environment(NavigationManager.self) var navigationManager
    @Environment(CanvasManager.self) var canvasManager
    @Environment(DataManager.self) var dataManager

    let asset: Asset
    let proxy: GeometryProxy

    @State var colours: [Color] = []

    @State var isLoading = true

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 0) {
                asset.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16.0))
                    .padding(.vertical, 24)
                    .shadow(radius: 4)
                    .onTapGesture {
                        navigationManager.navigateOnto(page: .editor(asset: asset, colours: colours))
                        canvasManager.resetInteractableState(toggleScaleToFit: false)
                    }
                    .opacity(isLoading ? 0.7 : 1)
                    .disabled(isLoading)
                    .animation(.default, value: isLoading)
                    .overlay(alignment: .topTrailing) {
                        if case .custom = asset.typeContent {
                            Button {
                                try? dataManager.deleteCustomArtwork(forId: asset.id)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.gray)
                                    .padding(12)
                                    .background {
                                        Circle()
                                            .fill(.black.opacity(0.4))
                                    }
                            }
                            .offset(x: -12, y: 32)
                        }
                    }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(asset.title)
                            .font(.title.bold())
                        Spacer()
                    }

                    Text(asset.description)
                        .padding(.bottom, 32)

                    Label {
                        Text(asset.tooltip)
                    } icon: {
                        Image(systemName: "info.circle")
                    }
                    .foregroundStyle(.gray)
                    .shadow(radius: 2)
                    .padding(.bottom, 32)

                    HStack {
                        Group {
                            ForEach(0..<6) { index in
                                Rectangle()
                                    .fill(colours.count == 7 ? colours[index] : .black)
                                    .opacity(isLoading ? 0.4 : 1)
                                    .frame(width: 24, height: 24)
                                    .transition(.opacity)
                            }
                        }
                        .animation(.default, value: colours)

                        Spacer()
                        buttonView {
                            navigationManager.navigateOnto(page: .editor(asset: asset, colours: colours))
                            canvasManager.resetInteractableState(toggleScaleToFit: false)
                        }
                    }
                    .padding(.trailing)
                }
                .foregroundStyle(.white)

                Spacer()
            }
            .padding()
            .background(
                asset.image
                    .resizable()
                    .saturation(0.6)
                    .scaledToFill()
                    .blur(radius: 20)
                    .opacity(0.6)
            )
            .frame(minHeight: proxy.size.height)
        }
        .onAppear {
            Task {
                let colours = await asset.fetchPopulousColours()
                self.colours = colours
                isLoading = false
            }
        }
    }

    func buttonView(_ action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: "paintbrush")
                .font(.system(size: 24))
                .padding()
                .foregroundStyle(isLoading ? .gray : .white)
        }
        .background {
            Circle()
                .fill(.clear)
                .stroke(Gradients.defaultGradient, lineWidth: 5)
//                .foregroundStyle(Gradients.defaultGradient)
                .blur(radius: isLoading ? 10 : 1)
                .opacity(isLoading ? 0 : 0.8)
                .shadow(radius: 4)
        }
        .opacity(isLoading ? 0.3 : 1)
        .disabled(isLoading)
        .animation(.default, value: isLoading)
    }
}
