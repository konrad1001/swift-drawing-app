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
    var bgColour: Color = .white
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

    func resetInteractableState(toggleScaleToFit: Bool = true) {
        currentZoom = 0.0
        totalZoom = 1.0
        offset = .zero
        lastOffset = .zero

        if toggleScaleToFit {
            scaledToFit.toggle()
        } else {
            scaledToFit = true
        }
    }
}


