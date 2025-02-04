//
//  Drawing.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/23/25.
//

import Foundation
import SwiftData
import UIKit
import PencilKit

@Model
class Drawing {
    var id: UUID
    var data: Data?
    var tag: String

    init(id: UUID = UUID(), data: Data? = nil, tag: String) {
        self.id = id
        self.data = data
        self.tag = tag
    }

    func toImage(size: CGSize) -> UIImage? {
        guard let data = self.data, let drawing = try? PKDrawing(data: data) else {
            return nil
        }

        let imgRect = CGRect(origin: .zero, size: size)

        return drawing.image(from: imgRect, scale: 1.0)
    }
}

