//
//  PalatteView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/30/25.
//

import SwiftUI

struct PalatteView: View {
    @Environment(CanvasManager.self) var canvasManager

    let colours: [Color]

    init(_ colours: [Color]) {
        assert(colours.count == 7)
        self.colours = colours
    }

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
                ColorPicker("Canvas", selection: $canvasManager.bgColor, supportsOpacity: false)
                    .frame(width: 0)
                    .offset(x: -3)  // offset padding from label
                Spacer()
            }
            .foregroundStyle(.white)


            VStack {
                iconButton(systemName: "magnifyingglass") {
                    canvasManager.resetInteractableState()
                }
                iconButton(systemName: "pencil") {
                    canvasManager.isDrawing = true
                    canvasManager.pencilType = .pencil
                }
                iconButton(systemName: "pencil") {
                    canvasManager.isDrawing = true
                    canvasManager.pencilType = .pencil
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.black.opacity(0.4))
        )
        .onAppear {
            canvasManager.bgColor = colours[0]
            canvasManager.color = colours[1]
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
