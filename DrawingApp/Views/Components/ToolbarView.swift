//
//  ToolbarView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/26/25.
//

import SwiftUI

struct ToolbarView: View {
    enum Tool {
        case pencil
        case watercolour
        case brush
        case eraser

        var systemName: String {
            switch self {
            case .pencil:
                "pencil"
            case .watercolour:
                "paintbrush.pointed"
            case .brush:
                "paintbrush"
            case .eraser:
                "eraser"
            }
        }
    }

    @Environment(CanvasManager.self) var canvasManager
    @Environment(\.undoManager) private var undoManager

    @State var selectedTool: Tool = .pencil

    let proxy: GeometryProxy

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    iconButton(tool: .pencil) {
                        canvasManager.isDrawing = true
                        canvasManager.pencilType = .pencil
                    }

                    iconButton(tool: .watercolour) {
                        canvasManager.isDrawing = true
                        canvasManager.pencilType = .watercolor
                    }

                    iconButton(tool: .brush) {
                        canvasManager.isDrawing = true
                        canvasManager.pencilType = .crayon
                    }

                    iconButton(tool: .eraser) {
                        canvasManager.isDrawing = false
                    }
                }

                SliderView()
            }
            .frame(maxWidth: proxy.size.width * (1/2))


            Spacer()

            iconButton(systemName: "arrow.uturn.backward", bold: false) {
                undoManager?.undo()
            }
            iconButton(systemName: "arrow.uturn.forward", bold: false) {
                undoManager?.redo()
            }
        }
    }
}

// View builders
extension ToolbarView {
    func iconButton(tool: Tool, bold: Bool = true, _ action: @escaping () -> Void) -> some View {
        let isSelected = (tool == selectedTool)

        return Button {
            action()
            selectedTool = tool
        } label: {
            Image(systemName: tool.systemName)
                .font(bold ? .title3.bold() : .title3)
                .padding(12)
                .foregroundStyle(.white)
                .background(
                    Circle()
                        .fill(.clear)
                        .stroke(Gradients.defaultGradient, lineWidth: 5)
                        .blur(radius: isSelected ? 1 : 10)
                        .opacity(isSelected ? 0.8 : 0)
                )
                .animation(.default, value: isSelected)
        }


    }

    // Without selection backgrounds
    func iconButton(systemName: String, bold: Bool = true, _ action: @escaping () -> Void) -> some View {
        Button(action: action)  {
            Image(systemName: systemName)
                .font(bold ? .title3.bold() : .title3)
                .padding(12)
                .foregroundStyle(.white)
        }
    }
}
