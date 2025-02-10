//
//  Asset.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/23/25.
//

import SwiftUI

struct Asset: Hashable, Identifiable {
    let image: Image
    let id: String
    let title: String
    let description: String
    let tooltip: String

    init(image: Image, id: String, title: String, description: String, tooltip: String) {
        self.image = image
        self.id = id
        self.title = title
        self.description = description
        self.tooltip = tooltip
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Fetch 7 most populous colours
    func fetchPopulousColours() async -> [Color] {
        var colourMap = [Color: Int]()

        guard let uiImage = UIImage(named: self.id),
              let pixelReader = ImagePixelReader(image: uiImage) else {
            return Array(repeating: Color.black, count: 7)
        }

        for x in stride(from: 1, to: Int(uiImage.size.width), by: 2) {
            for y in stride(from: 1, to: Int(uiImage.size.height), by: 2) {
                if let pixelColor = pixelReader.colorAt(x: x, y: y) {
                    colourMap[pixelColor] = (colourMap[pixelColor] ?? 0) + 1
                }
            }
        }

        let sortedColours = colourMap.sorted(by: { $0.value < $1.value })
        let topSix = sortedColours.prefix(7)

        return Array(topSix.map { $0.key })
    }
}
