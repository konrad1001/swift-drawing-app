//
//  CustomArtwork.swift
//  DrawingApp
//
//  Created by Konrad Painta on 2/10/25.
//

import SwiftData
import SwiftUI

@Model
class CustomArtwork {
    var id: UUID
    var imageData: Data
    var title: String
    var dateCreated: Date

    init(id: UUID = UUID(), imageData: Data, title: String, dateCreated: Date) {
        self.id = id
        self.imageData = imageData
        self.title = title
        self.dateCreated = dateCreated
    }
}

extension CustomArtwork {
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter.string(from: self.dateCreated)
    }
    var asset: Asset {
        .init(
            typeContent: .custom(imageData: imageData),
            id: id,
            title: title,
            description: "",
            tooltip: "Created on \(shortDate)",
            assetTag: dateCreated.ISO8601Format() + title
        )
    }
}



