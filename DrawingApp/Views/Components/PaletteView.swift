//
//  PalatteView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/30/25.
//

import SwiftUI

struct PaletteView: View {
    @Environment(CanvasManager.self) var canvasManager
    @Environment(DataManager.self) var dataManager

    let asset: Asset
    let colours: [Color]

    var body: some View {
        @Bindable var canvasManager = canvasManager

        HStack(alignment: .top) {
            VStack {
                Spacer()
                ForEach(1..<7) { index in
                    palatteColour(colours[index])
                        .frame(width: 24, height: 24)
                }
                ColorPicker("Brush", selection: $canvasManager.color, supportsOpacity: true)
                    .frame(width: 0)
                    .offset(x: -3)
                    .overlay(
                        Image(systemName: "paintbrush.pointed")
                            .foregroundStyle(.gray)
                            .offset(x: 35)
                    )
                ColorPicker("Canvas", selection: $canvasManager.bgColour, supportsOpacity: false)
                    .frame(width: 0)
                    .offset(x: -3)
                    .overlay(
                        Image(systemName: "photo.artframe")
                            .foregroundStyle(.gray)
                            .offset(x: 35)
                    )
                Spacer()
            }
            .foregroundStyle(.white)

            VStack {
                iconButton(systemName: "magnifyingglass") {
                    canvasManager.resetInteractableState()
                }
                // TODO: rework this, unlimited blank canvas creation
                iconButton(systemName: "photo.badge.plus.fill") {
                    let randomBgColour = colours.randomElement() ?? canvasManager.bgColour
                    try? dataManager.createNewDrawing(forAsset: asset, withBackgroundColour: UIColor(randomBgColour))
                    canvasManager.bgColour =  randomBgColour
                }

                Spacer()
            }
        }

        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.black.opacity(0.4))
        )
        .onChange(of: canvasManager.bgColour) { _, newColour in
            if case let .editing(drawing) = dataManager.editingState[asset] {
                drawing.setBgColour(UIColor(newColour))
            }
        }
    }

    func palatteColour(_ colour: Color) -> some View {
        Button {
            canvasManager.color = colour
        } label: {
            Rectangle().fill(colour)
        }

    }

    func iconButton(systemName: String, bold: Bool = true, _ action: @escaping () -> Void) -> some View {
        Button(action: action)  {
            Image(systemName: systemName)
                .font(bold ? .title3.bold() : .title3)
                .padding(12)
                .foregroundStyle(.white)
        }
    }
}
