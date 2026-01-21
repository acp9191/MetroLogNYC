import Foundation
import CoreLocation

/// Represents the shape data for a subway line
struct SubwayLineShape: Sendable {
    let lineId: String
    let color: String  // Hex color from GTFS
    let shapes: [[CLLocationCoordinate2D]]  // Multiple shapes per line (for branches, express/local variants)
}

/// JSON structure for Codable parsing
private struct ShapeJSON: Codable {
    let color: String
    let shapes: [[[Double]]]
}

/// Service to load and provide subway line shape data
@MainActor
class SubwayShapeService {
    static let shared = SubwayShapeService()

    private var lineShapes: [String: SubwayLineShape] = [:]
    private(set) var isLoaded = false
    private var loadTask: Task<Void, Never>?

    private init() {}

    /// Preload shapes in background - call at app startup
    func preload() {
        guard loadTask == nil && !isLoaded else { return }
        loadTask = Task.detached(priority: .userInitiated) {
            await self.loadShapesAsync()
        }
    }

    /// Load shapes asynchronously
    private func loadShapesAsync() async {
        guard !isLoaded else { return }

        guard let url = Bundle.main.url(forResource: "subway_shapes", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load subway_shapes.json")
            return
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

                shapes[lineId] = SubwayLineShape(
                    lineId: lineId,
                    color: lineData.color,
                    shapes: coordinates
                )
            }

            await MainActor.run {
                self.lineShapes = shapes
                self.isLoaded = true
            }
        } catch {
            print("Error parsing subway_shapes.json: \(error)")
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
        return Array(lineShapes.values)
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
