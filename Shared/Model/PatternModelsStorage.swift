//
//  PatternModelsStorage.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 16/10/2022.
//

import Foundation

final class PatternModelsStorage {
    static let shared = PatternModelsStorage()
    
    var keys: [String] {
        return registry.values
            .sorted(by: { $0.order < $1.order })
            .map(\.name)
    }
    private var registry: [String: PatternModel]
    
    init() {
        let models = Self.loadStoredPatterns()
        registry = models.reduce(into: [:], { $0[$1.name] = $1 })
    }
    
    func pattern(for key: String) -> PatternModel? {
        registry[key]
    }
    
    private static func loadStoredPatterns() -> [PatternModel] {
        guard let resources = Bundle.main.resourcePath else { return [] }
        do {
            let content = try FileManager.default.contentsOfDirectory(atPath: resources)
            let resourcesURL = URL(fileURLWithPath: resources, isDirectory: true)
            let decoder = JSONDecoder()
            let jsonModels = try content.filter({ $0.contains("json") })
                .compactMap({ URL(fileURLWithPath: $0, relativeTo: resourcesURL) })
                .map({ try Data(contentsOf: $0) })
                .map({ try decoder.decode(PatternModel.self, from: $0) })
            let rleModels = try content.filter({ $0.contains("rle") })
                .compactMap({ URL(fileURLWithPath: $0, relativeTo: resourcesURL) })
                .enumerated()
                .map({ try RLEParser.parse(url: $0.element, order: jsonModels.count + $0.offset) })
            return jsonModels + rleModels
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

struct PatternModel: Codable {
    let order: Int
    let name: String
    let points: [Int32]
}

struct Pattern {
    let origin: (x: UInt32, y: UInt32)
    let model: PatternModel
}
