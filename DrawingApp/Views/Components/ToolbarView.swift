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
                    Circle().fill(.blue)
                        .opacity(isSelected ? 1.0 : 0)
//                        .transition(.scale)

                )
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




// Experimental
struct SecondaryToolbarView: View {
    @Environment(CanvasManager.self) var canvasManager
    @Environment(\.undoManager) private var undoManager

    @State var isSelected = false
    @State var isSelectedb = false

    var body: some View {
        HStack(spacing: -32) {
            Group {
                Image("paintbrush")
                    .resizable()
                    .frame(width: isSelected ? 250 : 240, height: isSelected ? 190 : 180)
                    .offset(y: isSelected ? -12 : 0)
                    .scaledToFit()
                    .shadow(color: .black,
                            radius: isSelected ? 8 : 2,
                            x: isSelected ? 0 : -2,
                            y: isSelected ? 18 : 8)
            }
            .onTapGesture {
                withAnimation {
                    isSelected.toggle()
                }
            }

            Group {
                Image("paintbrush")
                    .resizable()
                    .frame(width: isSelectedb ? 250 : 240, height: isSelectedb ? 190 : 180)
                    .offset(y: isSelectedb ? -12 : 0)
                    .scaledToFit()
                    .shadow(color: .black,
                            radius: isSelected ? 8 : 2,
                            x: isSelectedb ? 0 : -2,
                            y: isSelectedb ? 18 : 8)
            }
            .onTapGesture {
                withAnimation {
                    isSelectedb.toggle()
                }
            }


            Spacer()
        }
    }
}
