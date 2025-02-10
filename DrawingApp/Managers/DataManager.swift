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
import PencilKit

@Observable final class DataManager {
    enum EditingState: Equatable {
        case idle
        case editing(_ drawing: Drawing)
    }

    enum Error: Swift.Error {
        case failedToFetchDataFromUrl
        case failedToDecodeArtworkJSON
        case failedToLoadCustomArtworksFromData
    }

    let modelContext: ModelContext

    // State
    var editingState: EditingState = .idle
    var firstHistoric: Asset? {
        assets.first { if case .historic = $0.typeContent { return true } else { return false } }
    }
    var firstCustom: Asset? {
        assets.first { if case .custom = $0.typeContent { return true } else { return false } }
    }

    // Stores
    var drawings = [Drawing]()
    var assets = [Asset]()

    init?(modelContext: ModelContext) {
        self.modelContext = modelContext

        do {
            try self.fetchDrawingData()
        } catch {
            print(error)
            return nil
        }

        if let assetsData = try? self.fetchAssetData() {
            assets = assetsData
        } else {
            return nil
        }
    }

    // MARK: - Assets
    func createCustomArtwork(_ artwork: CustomArtwork) throws {
        modelContext.insert(artwork)
        try modelContext.save()

        assets.append(artwork.asset)
    }

    func deleteCustomArtwork(forId id: UUID) throws {
        try modelContext.delete(model: CustomArtwork.self, where: #Predicate { artwork in
            artwork.id == id
        })

        assets = assets.filter { $0.id != id }
    }

    // MARK: - Drawings
    func selectDrawing(_ drawing: Drawing?) {
        if let drawing {
            editingState = .editing(drawing)
        } else {
            editingState = .idle
        }
    }

    func createNewDrawing(forTag tag: String, withBackgroundColour bgColour: UIColor? = nil) throws {
        let blankDrawing = PKDrawing()

        let newDrawing = Drawing(data: blankDrawing.dataRepresentation(), tag: tag)

        if let bgColour {
            newDrawing.setBgColour(bgColour)
        }

        modelContext.insert(newDrawing)
        try modelContext.save()

        drawings.append(newDrawing)
        editingState = .editing(newDrawing)
    }

    func deleteDrawing(_ drawing: Drawing) throws {
        modelContext.delete(drawing)
        try modelContext.save()

        drawings = drawings.filter { $0.id != drawing.id }

        editingState = .idle
    }

    func deleteAllDrawings() throws {
        for drawing in drawings {
            modelContext.delete(drawing)
        }
        try modelContext.save()

        drawings = []

        editingState = .idle
    }
}

// MARK: - Fetch 
extension DataManager {
    private func fetchDrawingData() throws {
        let descriptor = FetchDescriptor<Drawing>()
        drawings = try modelContext.fetch(descriptor)
    }

    private func fetchCustomAssets() throws -> [Asset] {
        let descriptor = FetchDescriptor<CustomArtwork>()
        return try modelContext.fetch(descriptor).map { $0.asset }
    }

    private func fetchAssetData() throws -> [Asset] {
        guard let url = Bundle.main.url(forResource: "Data", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw Error.failedToFetchDataFromUrl
        }

        guard let customAssets = try? fetchCustomAssets() else {
            throw Error.failedToLoadCustomArtworksFromData
        }

        do {
            let data = try JSONDecoder().decode(ArtworkData.self, from: data)
            let assets = data.artworks.map { $0.asset }
            return assets + customAssets
        } catch {
            print(error)
            throw Error.failedToDecodeArtworkJSON
        }
    }
}

