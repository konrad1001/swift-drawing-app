//
//  CanvasManager.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/23/25.
//

import Observation
import PencilKit
import SwiftData
import SwiftUI

@Observable final class CanvasManager {
    // Drawing state
    var canvas = PKCanvasView()
    var isDrawing = true
    var color: Color = .black
    var bgColor: Color = .white
    var pencilType: PKInkingTool.InkType = .pencil
    var widthSlider: CGFloat = 0.5
    var widthRange: ClosedRange<CGFloat> = 5...32

    // Interactable state
    var currentZoom = 0.0
    var totalZoom = 1.0
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    var scaledToFit: Bool = true

    // Metadata
    var canvasSize: CGSize? = nil

    func resetInteractableState() {
        currentZoom = 0.0
        totalZoom = 1.0
        offset = .zero
        lastOffset = .zero

        scaledToFit.toggle()
    }

    func toImage(drawing: Drawing) -> UIImage? {
        guard let data = drawing.data,
              let drawing = try? PKDrawing(data: data),
              let size = self.canvasSize
        else {
            return nil
        }

        let imgRect = CGRect(origin: .zero, size: size)
        let img = drawing.image(from: imgRect, scale: 1.0)

        return img.withBackground(color: UIColor(self.bgColor))
    }
}


