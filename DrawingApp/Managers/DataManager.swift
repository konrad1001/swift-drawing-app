//
//  DataManager.swift
//  DrawingApp
//
//  Created by Konrad Painta on 1/30/25.
//

import Observation
import Foundation
import SwiftData
import SwiftUI

@Observable final class DataManager {
    enum EditingState {
        case idle
        case editing(_ drawing: Drawing)
    }

    enum Error: Swift.Error {
        case failedToFetchDataFromUrl
        case failedToDecodeArtworkJSON
    }

    let modelContext: ModelContext

    // State
    var editingState: EditingState = .idle

    // Stores
    var drawings = [Drawing]()
    var artworks = [Artwork]()

    init?(modelContext: ModelContext) {
        self.modelContext = modelContext

        do {
            try self.fetchDrawingData()
        } catch {
            print(error)
            return nil
        }

        print("fetched drawings")

        if let artworksData = try? self.fetchArtworkData() {
            artworks = artworksData
        } else {
            return nil
        }
    }

    func createNewDrawing(forTag tag: String) throws {
        let newDrawing = Drawing(data: nil, tag: tag)
        modelContext.insert(newDrawing)
        try modelContext.save()

        drawings.append(newDrawing)
        editingState = .editing(newDrawing)
    }

    func deleteAll() {
        for drawing in drawings {
            modelContext.delete(drawing)
        }
        drawings = []
    }
}

// MARK: - Fetch 
extension DataManager {
    private func fetchDrawingData() throws {
        let descriptor = FetchDescriptor<Drawing>()
        drawings = try modelContext.fetch(descriptor)
    }

    private func fetchArtworkData() throws -> [Artwork] {
        guard let url = Bundle.main.url(forResource: "Data", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw Error.failedToFetchDataFromUrl
        }

        do {
            let data = try JSONDecoder().decode(ArtworkData.self, from: data)
            return data.artworks
        } catch {
            print(error)
            throw Error.failedToDecodeArtworkJSON
        }
    }
}

extension DataManager {
    // Fetch 7 most populous colours
    static func fetchPopulousColours(for artwork: Artwork) async -> [Color] {
        var colourMap = [Color: Int]()

        guard let uiImage = UIImage(named: artwork.assetTag),
              let pixelReader = ImagePixelReader(image: uiImage) else {
            return []
        }

        for x in stride(from: 1, to: Int(uiImage.size.width), by: 2) {
            for y in stride(from: 1, to: Int(uiImage.size.height), by: 2) {
                if let pixelColor = pixelReader.colorAt(x: x, y: y) {
                    colourMap[pixelColor] = (colourMap[pixelColor] ?? 0) + 1
                }
            }
        }

        let sortedColours = colourMap.sorted(by: { $0.value < $1.value })
        let topSix = sortedColours.prefix(7)

        return Array(topSix.map { $0.key })
    }
}

