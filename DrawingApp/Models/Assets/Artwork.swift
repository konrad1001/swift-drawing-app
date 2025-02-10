//
//  Artwork.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/28/25.
//

import SwiftUI

struct Artwork: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let description: String
    let tooltip: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case tooltip
    }

    init(id: String, title: String, description: String, tooltip: String) {
        self.id = id
        self.title = title
        self.description = description
        self.tooltip = tooltip
    }
}

extension Artwork {
    var asset: Asset {
        .init(
            image: Image(id),
            id: id,
            title: title,
            description: description,
            tooltip: tooltip)
    }

    static let example = Artwork(
            id: "starry_night",
            title: "Mona Lisa (Preview)",
            description: "A preview of the Mona Lisa description.",
            tooltip: "Preview tooltip: Try capturing the smile."
        )
}

struct ArtworkData: Codable {
    let artworks: [Artwork]
}


