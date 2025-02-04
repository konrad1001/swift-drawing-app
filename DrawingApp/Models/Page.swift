//
//  Page.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/30/25.
//

import SwiftUICore
//
//struct Page: Hashable {
//    let artwork: Artwork
//    let colours: [Color]
//}

enum Page: Hashable {
    case editor(artwork: Artwork, colours: [Color])
    case stage(artwork: Artwork)
}
