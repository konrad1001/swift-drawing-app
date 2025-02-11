//
//  SliderView.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/30/25.
//

import SwiftUI

struct SliderView: View {
    @Environment(CanvasManager.self) var canvasManager

    var body: some View {
        @Bindable var canvasManager = canvasManager

        Slider(value: $canvasManager.widthSlider)
            .tint(.clear)
            .background(
                GeometryReader { proxy in
                    Triangle()
                        .fill(Color(.white))
                        .opacity(0.8)
                        .mask(
                            LinearGradient(gradient:
                                Gradient(stops: [
                                    Gradient.Stop(color: .black, location: canvasManager.widthSlider - 0.08),
                                    Gradient.Stop(color: .clear, location: canvasManager.widthSlider - 0.05)
                                ]),
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .allowsHitTesting(false)
                }
            )
    }
}
