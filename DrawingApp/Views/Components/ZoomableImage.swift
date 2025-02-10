//
//  ZoomableImage.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/31/25.
//

import SwiftUI

struct ZoomableImage: View {
    @Environment(CanvasManager.self) var canvasManager

    var currentZoom: Double { canvasManager.currentZoom }
    var totalZoom: Double { canvasManager.totalZoom }

    var offset: CGSize { canvasManager.offset }
    var lastOffset: CGSize { canvasManager.lastOffset }

    let asset: Asset

    var body: some View {
        Group {
            asset.image
                .resizable()
                .aspectRatio(contentMode: canvasManager.scaledToFit ? .fit : .fill)
                .clipShape(RoundedRectangle(cornerRadius: 16.0))
                .shadow(radius: 4)
                .offset(offset)
                .scaleEffect(totalZoom + currentZoom)
        }
        .gesture(
            MagnifyGesture()
                .onChanged { value in
                    canvasManager.currentZoom  = value.magnification - 1
                }
                .onEnded { value in
                    canvasManager.totalZoom = min(max(currentZoom + totalZoom, 0.5), 3.0)
                    canvasManager.currentZoom  = 0
                }
                .simultaneously(
                        with: DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                withAnimation(.interactiveSpring()) {
                                    canvasManager.offset.width = value.translation.width + lastOffset.width
                                    canvasManager.offset.height = value.translation.height + lastOffset.height
                                }
                            })
                            .onEnded({ _ in
                                canvasManager.lastOffset = offset
                            })

                    )
        )
    }
}
