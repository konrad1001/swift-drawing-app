//
//  Page.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/30/25.
//

import SwiftUI

enum Page: Hashable {
    case editor(asset: Asset, colours: [Color])
    case stage(asset: Asset)
}
