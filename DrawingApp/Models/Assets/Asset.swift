//
//  Asset.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/23/25.
//

import SwiftUI

enum AssetTypeSpecificContent: Equatable {
    case historic(assetTag: String)
    case custom(imageData: Data)
}

struct Asset: Hashable, Identifiable {
    let typeContent: AssetTypeSpecificContent
    let id: UUID
    let title: String
    let description: String
    let tooltip: String
    let assetTag: String

    init(typeContent: AssetTypeSpecificContent, id: UUID, title: String, description: String, tooltip: String, assetTag: String) {
        self.typeContent = typeContent
        self.id = id
        self.title = title
        self.description = description
        self.tooltip = tooltip
        self.assetTag = assetTag
    }

    var image: Image {
        switch self.typeContent {
        case .historic(let assetTag):
            Image(assetTag)
        case .custom(let imageData):
            // TODO: placeholder images
            Image(uiImage: UIImage(data: imageData)!)
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Fetch N most populous colours
    func fetchPopulousColours(_ n: Int = 7, step: Int = 2) async -> [Color] {
        var colourMap = [Color: Int]()
        var uiImage: UIImage?

        switch self.typeContent {
        case .historic(let assetTag):
            uiImage = UIImage(named: assetTag)
        case .custom(let imageData):
            uiImage = UIImage(data: imageData)
        }

        guard let uiImage, let pixelReader = ImagePixelReader(image: uiImage) else {
            return Array(repeating: Color.black, count: n)
        }

        for x in stride(from: 1, to: Int(uiImage.size.width), by: step) {
            for y in stride(from: 1, to: Int(uiImage.size.height), by: step) {
                if let pixelColor = pixelReader.colorAt(x: x, y: y) {
                    colourMap[pixelColor] = (colourMap[pixelColor] ?? 0) + 1
                }
            }
        }

        let sortedColours = colourMap.sorted(by: { $0.value < $1.value })
        let head = sortedColours.prefix(n)
        var mutHead = head

        while mutHead.count < n {
            mutHead.append(head[mutHead.count % head.count])
        }

        let output = Array(mutHead.map { $0.key })

        assert(output.count == n, "Output is too short")

        return output
    }
}
