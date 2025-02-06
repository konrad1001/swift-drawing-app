//
//  UIColor+Extensions.swift
//  DrawingApp
//
//  Created by Konrad Painta on 2/6/25.
//

import UIKit

extension UIColor {
    convenience init?(hex: String) {
            var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            if hexString.hasPrefix("#") {
                hexString.removeFirst()
            }

            let scanner = Scanner(string: hexString)

            var rgbValue: UInt64 = 0
            guard scanner.scanHexInt64(&rgbValue) else {
                return nil
            }

            var red, green, blue, alpha: UInt64
            switch hexString.count {
            case 6:
                red = (rgbValue >> 16)
                green = (rgbValue >> 8 & 0xFF)
                blue = (rgbValue & 0xFF)
                alpha = 255
            case 8:
                red = (rgbValue >> 16)
                green = (rgbValue >> 8 & 0xFF)
                blue = (rgbValue & 0xFF)
                alpha = rgbValue >> 24
            default:
                return nil
            }

            self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alpha) / 255)
        }

    func toHex() -> String {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0

            guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
                assertionFailure("Failed to get RGBA components from UIColor")
                return "#000000"
            }

            // Clamp components to [0.0, 1.0]
            red = max(0, min(1, red))
            green = max(0, min(1, green))
            blue = max(0, min(1, blue))
            alpha = max(0, min(1, alpha))

            if alpha == 1 {
                // RGB
                return String(
                    format: "#%02lX%02lX%02lX",
                    Int(round(red * 255)),
                    Int(round(green * 255)),
                    Int(round(blue * 255))
                )
            } else {
                // RGBA
                return String(
                    format: "#%02lX%02lX%02lX%02lX",
                    Int(round(red * 255)),
                    Int(round(green * 255)),
                    Int(round(blue * 255)),
                    Int(round(alpha * 255))
                )
            }
        }
}
