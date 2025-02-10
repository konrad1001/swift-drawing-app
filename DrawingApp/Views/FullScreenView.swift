//
//  FullScreenView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/28/25.
//

import SwiftUI

struct FullScreenView: View {
    @Environment(NavigationManager.self) var navigationManager

    let asset: Asset
    let proxy: GeometryProxy

    @State var colours: [Color] = []

    @State var isLoading = true

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 0) {
//                Spacer()
                asset.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16.0))
                    .padding(.vertical, 24)
                    .shadow(radius: 4)
                    .onTapGesture {
                        navigationManager.navigateOnto(page: .editor(asset: asset, colours: colours))
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
                    .padding(.bottom, 32)

                    HStack {
                        ForEach(0..<6) { index in
                            Rectangle()
                                .fill(colours.count == 7 ? colours[index] : .black)
                                .opacity(isLoading ? 0 : 1)
                                .frame(width: 24, height: 24)
                                .transition(.opacity)
                        }
                        .animation(.default, value: colours)

                        Spacer()
                        Button {
                            navigationManager.navigateOnto(page: .editor(asset: asset, colours: colours))
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
                asset.image
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
                let colours = await asset.fetchPopulousColours()
                self.colours = colours
                isLoading = false
            }
        }
    }
}
