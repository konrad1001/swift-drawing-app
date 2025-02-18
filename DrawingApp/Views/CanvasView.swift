//
//  ContentView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/21/25.
//

import SwiftUI
import PencilKit

struct UICanvasView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme

    @Bindable var canvasManager: CanvasManager
    
    var drawing: Drawing

    var width: CGFloat {
        canvasManager.widthSlider * (canvasManager.widthRange.upperBound - canvasManager.widthRange.lowerBound) + canvasManager.widthRange.lowerBound
    }

    var ink: PKInkingTool {
        let interfaceStyle: UIUserInterfaceStyle = (colorScheme == .light) ? .light : .dark
        let adjustedColour = PKInkingTool.convertColor(UIColor(canvasManager.color), from: interfaceStyle, to: .light)
        return PKInkingTool(canvasManager.pencilType, color: adjustedColour, width: width)
       }

    var eraser: PKEraserTool {
        PKEraserTool(.bitmap, width: width)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func createPKDrawing(for drawing: Drawing) -> PKDrawing {
        guard let data = drawing.data, let drawing = try? PKDrawing(data: data) else {
            return PKDrawing()
        }

        return drawing
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()

        let drawing = createPKDrawing(for: drawing)
        canvas.drawing = drawing

        canvas.backgroundColor = UIColor(canvasManager.bgColour)
//        canvas.overrideUserInterfaceStyle = .light

        canvas.drawingPolicy = .anyInput
        canvas.isOpaque = true
        canvas.tool = canvasManager.isDrawing ? ink : eraser
        canvas.alwaysBounceVertical = true

        canvas.becomeFirstResponder()

        canvas.delegate = context.coordinator

        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = canvasManager.isDrawing ? ink : eraser
        uiView.backgroundColor = UIColor(canvasManager.bgColour)
    }
}

extension UICanvasView {
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let canvas: UICanvasView

        init(_ canvas: UICanvasView) {
            self.canvas = canvas
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            canvas.drawing.data = canvasView.drawing.dataRepresentation()
        }
    }
}
