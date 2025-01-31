//
//  Artwork.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/28/25.
//

struct Artwork: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let description: String
    let tooltip: String
    let assetTag: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case tooltip
        case assetTag = "asset_tag"
    }

    init(id: String, title: String, description: String, tooltip: String, assetTag: String) {
        self.id = id
        self.title = title
        self.description = description
        self.tooltip = tooltip
        self.assetTag = assetTag
    }
}

extension Artwork {
    static let example = Artwork(
            id: "starry_night",
            title: "Mona Lisa (Preview)",
            description: "A preview of the Mona Lisa description.",
            tooltip: "Preview tooltip: Try capturing the smile.",
            assetTag: "starry_night"
        )

    static func decode() throws {
        
    }
}

struct ArtworkData: Codable {
    let artworks: [Artwork]
}


