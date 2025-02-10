//
//  Drawing.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/23/25.
//

import SwiftData
import SwiftUI
import PencilKit

@Model
class Drawing {
    var id: UUID
    var data: Data?
    var tag: String

    private var bgColourHex: String

    init(id: UUID = UUID(),
         data: Data? = nil,
         bgColourHex: String = "#ffffff",
         tag: String) {
        self.id = id
        self.data = data
        self.bgColourHex = bgColourHex
        self.tag = tag
    }

    func getBgColour() -> UIColor {
        if let colour = UIColor(hex: bgColourHex) {
            return colour
        } else {
            return  .white
        }
    }

    func setBgColour(_ colour: UIColor) {
        bgColourHex = colour.toHex()
    }

    func toImage(size: CGSize) -> UIImage? {
        guard let data = self.data, let drawing = try? PKDrawing(data: data) else {
            return nil
        }

        let imgRect = CGRect(origin: .zero, size: size)
        let img = drawing.image(from: imgRect, scale: 1.0)

        return img.withBackground(color: getBgColour())
    }
}


