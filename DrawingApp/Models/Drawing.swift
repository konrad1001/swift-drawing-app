//
//  Drawing.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/23/25.
//

import Foundation
import SwiftData

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
}

