//
//  ContentView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/21/25.
//

import SwiftUI
import PencilKit

struct UICanvasView: UIViewRepresentable {
    @Bindable var canvasManager: CanvasManager
    
    var drawing: Drawing

    var width: CGFloat {
        canvasManager.widthSlider * (canvasManager.widthRange.upperBound - canvasManager.widthRange.lowerBound) + canvasManager.widthRange.lowerBound
    }

    var ink: PKInkingTool {
        PKInkingTool(canvasManager.pencilType, color: UIColor(canvasManager.color), width: width)
       }

    var eraser: PKEraserTool {
        PKEraserTool(.bitmap, width: width)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Maybe do error checking here
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

        canvas.drawingPolicy = .anyInput

        canvas.isOpaque = false

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
