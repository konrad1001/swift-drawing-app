//
//  Artwork.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/28/25.
//

import SwiftUI

struct ArtworkData: Codable {
    let artworks: [Artwork]
}

struct Artwork: Codable {
    let tag: String
    let title: String
    let description: String
    let tooltip: String

    enum CodingKeys: String, CodingKey {
        case tag
        case title
        case description
        case tooltip
    }

    init(tag: String, title: String, description: String, tooltip: String) {
        self.tag = tag
        self.title = title
        self.description = description
        self.tooltip = tooltip
    }
}

extension Artwork {
    var asset: Asset {
        .init(
            typeContent: .historic(assetTag: tag),
            id: UUID(),
            title: title,
            description: description,
            tooltip: tooltip,
            assetTag: tag)
    }

    static let example = Artwork(
            tag: "starry_night",
            title: "Mona Lisa (Preview)",
            description: "A preview of the Mona Lisa description.",
            tooltip: "Preview tooltip: Try capturing the smile."
        )
}



