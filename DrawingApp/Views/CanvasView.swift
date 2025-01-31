//
//  ContentView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/21/25.
//

import SwiftUI
import PencilKit

struct CanvasView: View {
    @Environment(CanvasManager.self) var canvasManager

    var drawing: Drawing
    let bgColour: Color?

    var body: some View {
        UICanvasView(canvasManager: canvasManager, drawing: drawing, bgColour: bgColour)
    }
}

struct UICanvasView: UIViewRepresentable {
    @Bindable var canvasManager: CanvasManager

    @Bindable var drawing: Drawing

    let bgColour: Color?

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

        if let bgColour {
            canvas.backgroundColor = UIColor(bgColour)
        }

        canvas.drawingPolicy = .anyInput

        canvas.tool = canvasManager.isDrawing ? ink : eraser
        canvas.alwaysBounceVertical = true

        let toolPicker = PKToolPicker.init()
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()

        canvas.delegate = context.coordinator

        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = canvasManager.isDrawing ? ink : eraser
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
