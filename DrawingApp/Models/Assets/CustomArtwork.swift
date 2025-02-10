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
    var asset: Asset {
        .init(
            image: Image(uiImage: UIImage(data: imageData)!),
            id: id.uuidString,
            title: title,
            description: "",
            tooltip: "")
    }
}



