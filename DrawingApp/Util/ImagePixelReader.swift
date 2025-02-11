//
//  ImagePixelReader.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/31/25.
//
// Inspired by answer in https://stackoverflow.com/questions/35462680/how-to-read-and-log-the-raw-pixels-of-image-in-swift-ios

import SwiftUI

final class ImagePixelReader {
    enum Component: Int {
        case r = 0
        case g = 1
        case b = 2
        case alpha = 3
    }

    let image: UIImage

    private var data: CFData
    private let pointer: UnsafePointer<UInt8>
    private let scale: Int

    init?(image: UIImage) {
        self.image = image

        guard let cfdata = self.image.cgImage?.dataProvider?.data,
              let pointer = CFDataGetBytePtr(cfdata) else {
            return nil
        }

        self.scale = Int(image.scale)
        self.data = cfdata
        self.pointer = pointer
    }

    init?(imageData: Data) {
        guard let uiImage = UIImage(data: imageData) else {
            return nil
        }

        self.image = uiImage

        guard let cfdata = uiImage.cgImage?.dataProvider?.data,
              let pointer = CFDataGetBytePtr(cfdata) else {
            return nil
        }

        self.scale = Int(image.scale)
        self.data = cfdata
        self.pointer = pointer
    }

    func colorAt(x: Int, y: Int) -> Color? {
        guard (CGFloat(x) < image.size.width) && (CGFloat(y) < image.size.height) else {
            return nil
        }

        let pixelPosition = (Int(image.size.width) * y * scale + x) * 4 * scale

        return Color(uiColor: getUIColor(r: pointer[pixelPosition + Component.r.rawValue],
                                         g: pointer[pixelPosition + Component.g.rawValue],
                                         b: pointer[pixelPosition + Component.b.rawValue],
                                         a: pointer[pixelPosition + Component.alpha.rawValue]))
    }

    private func getUIColor(r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> UIColor {
        UIColor(
            red: CGFloat(r)/255.0,
            green: CGFloat(g)/255.0,
            blue: CGFloat(b)/255.0,
            alpha: CGFloat(a)/255.0)
    }
}
