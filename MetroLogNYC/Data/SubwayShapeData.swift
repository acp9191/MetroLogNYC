import Foundation
import CoreLocation
import OSLog

private let logger = Logger(subsystem: "com.averypeterson.MetroLogNYC", category: "SubwayShapes")

/// Represents the shape data for a subway line
struct SubwayLineShape: Sendable {
    let lineId: String
    let shapes: [[CLLocationCoordinate2D]]  // Multiple shapes per line (for branches, express/local variants)
}

/// JSON structure for Codable parsing
private struct ShapeJSON: Codable {
    let shapes: [[[Double]]]
}

/// Service to load and provide subway line shape data
@MainActor
class SubwayShapeService {
    static let shared = SubwayShapeService()

    private var lineShapes: [String: SubwayLineShape] = [:]
    private var cachedAllShapes: [SubwayLineShape] = []
    private(set) var isLoaded = false
    private var loadTask: Task<Void, Never>?

    private init() {}

    /// Preload shapes in background - call at app startup
    func preload() {
        guard loadTask == nil && !isLoaded else { return }
        loadTask = Task { await self.loadShapesAsync() }
    }

    /// Load shapes asynchronously
    private func loadShapesAsync() async {
        guard !isLoaded else { return }

        // Decode off the main actor so the JSON parse doesn't block the UI thread,
        // then hop back to the main actor to publish the result.
        let shapes = await Task.detached(priority: .userInitiated) {
            Self.decodeShapes()
        }.value

        self.lineShapes = shapes
        self.cachedAllShapes = Array(shapes.values)
        self.isLoaded = true
    }

    /// Parse the bundled shapes JSON. Runs off the main actor.
    private nonisolated static func decodeShapes() -> [String: SubwayLineShape] {
        guard let url = Bundle.main.url(forResource: "subway_shapes", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            logger.error("Failed to load subway_shapes.json")
            return [:]
        }

        do {
            let json = try JSONDecoder().decode([String: ShapeJSON].self, from: data)
            var shapes: [String: SubwayLineShape] = [:]

            for (lineId, lineData) in json {
                let coordinates: [[CLLocationCoordinate2D]] = lineData.shapes.map { shapePoints in
                    shapePoints.compactMap { point in
                        guard point.count == 2 else { return nil }
                        return CLLocationCoordinate2D(latitude: point[0], longitude: point[1])
                    }
                }.filter { !$0.isEmpty }

                shapes[lineId] = SubwayLineShape(lineId: lineId, shapes: coordinates)
            }
            return shapes
        } catch {
            logger.error("Error parsing subway_shapes.json: \(error.localizedDescription)")
            return [:]
        }
    }

    /// Wait for shapes to be loaded
    func waitForLoad() async {
        if isLoaded { return }
        if loadTask == nil { preload() }
        await loadTask?.value
    }

    /// Get all line shapes (returns empty if not loaded yet)
    func allShapes() -> [SubwayLineShape] {
        return cachedAllShapes
    }

    /// Get shape data for a specific line
    func shapes(for lineId: String) -> SubwayLineShape? {
        return lineShapes[lineId]
    }

    /// Get shapes for multiple lines
    func shapes(for lineIds: [String]) -> [SubwayLineShape] {
        return lineIds.compactMap { lineShapes[$0] }
    }
}
