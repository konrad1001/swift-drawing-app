//
//  HomeView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 2/12/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(NavigationManager.self) var navigationManager

    @State private var isCollapsed: Bool = false

    let proxy: GeometryProxy

    var body: some View {
        VStack(alignment: .leading, spacing: 64) {
            Spacer()
            HStack {
                Text("Welcome to ") + Text("Muse")
                    .fontWeight(.bold)
                    .foregroundStyle(Gradients.varyingGradient)
                Spacer()
            }
            .font(.largeTitle)
            .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Muse is an iPhone app designed to get everybody into painting.")
                Text("Choose an existing Muse to copy from, or upload your own.")
            }
            .padding(.bottom, 132)

            HStack {
                Spacer()
                Button("Tap to get started") {
                    withAnimation(.spring(duration: 0.8)) {
                        navigationManager.homePageIsActive = false
                        isCollapsed = true
                    }
                }
                .fontWeight(.bold)
                .foregroundStyle(.gray)
                Spacer()
            }
            .padding()

            Spacer().frame(height: 50)
        }
        .padding(.horizontal, 48)
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
        .frame(height: isCollapsed ? 0 : proxy.size.height)
    }
}

#Preview {
    GeometryReader { geo in
        HomeView(proxy: geo)
            .environment(NavigationManager())
    }
}

