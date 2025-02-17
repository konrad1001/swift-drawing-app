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

    private let modelContext: ModelContext

    // State
    var editingState: [Asset: EditingState] = [:]

    var firstHistoric: Asset? {
        assets.first { if case .historic = $0.typeContent { return true } else { return false } }
    }
    var firstCustom: Asset? {
        assets.first { if case .custom = $0.typeContent { return true } else { return false } }
    }

    // Stores
    private(set) var drawings = [Drawing]()
    private(set) var assets = [Asset]()

    // Meta
    private(set) var customAssetCount = 0

    init?(modelContext: ModelContext) {
        self.modelContext = modelContext

        do {
            try self.fetchDrawingData()
            try self.fetchAssetData()
        } catch {
            print(error)
            return nil
        }

        for asset in assets {
            editingState[asset] = .idle
        }
    }

    // MARK: - Assets
    func createCustomAsset(_ artwork: CustomArtwork) throws {
        modelContext.insert(artwork)
        try modelContext.save()

        assets.append(artwork.asset)
        customAssetCount += 1
    }

    func deleteCustomAsset(asset: Asset) throws {
        let id = asset.id
        try modelContext.delete(model: CustomArtwork.self, where: #Predicate { artwork in
            artwork.id == id
        })

        try deleteAllDrawingsForDeletedAsset(asset: asset)

        assets = assets.filter { $0.id != asset.id }
        editingState = editingState.filter { $0.key.id != asset.id }
        customAssetCount = max(0, customAssetCount-1)
    }

    // MARK: - Drawings
    func selectDrawing(_ drawing: Drawing?, forAsset asset: Asset) {
        if let drawing {
            editingState[asset] = .editing(drawing)
        } else {
            editingState[asset] = .idle
        }
    }

    func createNewDrawing(forAsset asset: Asset, withBackgroundColour bgColour: UIColor? = nil) throws {
        let blankDrawing = PKDrawing()

        let newDrawing = Drawing(data: blankDrawing.dataRepresentation(), tag: asset.assetTag, dateCreated: Date())

        if let bgColour {
            newDrawing.setBgColour(bgColour)
        }

        modelContext.insert(newDrawing)
        try modelContext.save()

        drawings.append(newDrawing)
        editingState[asset] = .editing(newDrawing)
    }

    func clearDrawingForAsset(_ asset: Asset) throws {
        guard case let .editing(drawing) = editingState[asset] else {
            return
        }

        modelContext.delete(drawing)
        try modelContext.save()

        drawings = drawings.filter { $0.id != drawing.id }

        editingState[asset] = .idle
    }

    func deleteAllDrawings() throws {
        for drawing in drawings {
            modelContext.delete(drawing)
        }
        try modelContext.save()

        drawings = []
    }

    private func deleteAllDrawingsForDeletedAsset(asset: Asset) throws {
        drawings = drawings.compactMap({ drawing in
            if drawing.tag == asset.assetTag {
                modelContext.delete(drawing)
                return nil
            }
            return drawing
        })

        try modelContext.save()
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
        let assets = try modelContext.fetch(descriptor).map { $0.asset }

        customAssetCount = assets.count

        return assets
    }

    private func fetchAssetData() throws {
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
            self.assets = assets + customAssets
        } catch {
            print(error)
            throw Error.failedToDecodeArtworkJSON
        }
    }
}

