//
//  Gradients.swift
//  DrawingApp
//
//  Created by Konrad Painta on 2/13/25.
//

import SwiftUI

struct Gradients {
    private static let p1 = Color(uiColor: UIColor(hex: "#0567b7")!)
    private static let p2 = Color(uiColor: UIColor(hex: "#00d4ff")!)
    private static let p3 = Color(uiColor: UIColor(hex: "#1ea4bf")!)

    static let defaultGradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: p1, location: 0),
            .init(color: p2, location: 0.5),
            .init(color: p2, location: 0.7),
            .init(color: p3, location: 1)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )

    static let varyingGradient: any ShapeStyle = {
        if #available(iOS 18, *) {
            return MeshGradient(width: 2, height: 2, points: [
                [0, 0], [1, 0], [0, 1], [1, 1]
            ], colors: [p1, p2, p3, p1])
        } else {
            return defaultGradient
        }
    }()
}
