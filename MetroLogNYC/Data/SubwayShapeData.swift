import Foundation
import CoreLocation

/// Represents the shape data for a subway line
struct SubwayLineShape {
    let lineId: String
    let color: String  // Hex color from GTFS
    let shapes: [[CLLocationCoordinate2D]]  // Multiple shapes per line (for branches, express/local variants)
}

/// Service to load and provide subway line shape data
class SubwayShapeService {
    static let shared = SubwayShapeService()

    private var lineShapes: [String: SubwayLineShape] = [:]
    private var isLoaded = false

    private init() {}

    /// Load shapes from bundled JSON file
    func loadShapes() {
        guard !isLoaded else { return }

        guard let url = Bundle.main.url(forResource: "subway_shapes", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load subway_shapes.json")
            return
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Any]]

            for (lineId, lineData) in json ?? [:] {
                guard let color = lineData["color"] as? String,
                      let shapesArray = lineData["shapes"] as? [[[Double]]] else {
                    continue
                }

                var shapes: [[CLLocationCoordinate2D]] = []
                for shapePoints in shapesArray {
                    let coordinates = shapePoints.compactMap { point -> CLLocationCoordinate2D? in
                        guard point.count == 2 else { return nil }
                        return CLLocationCoordinate2D(latitude: point[0], longitude: point[1])
                    }
                    if !coordinates.isEmpty {
                        shapes.append(coordinates)
                    }
                }

                lineShapes[lineId] = SubwayLineShape(
                    lineId: lineId,
                    color: color,
                    shapes: shapes
                )
            }

            isLoaded = true
            print("Loaded shapes for \(lineShapes.count) subway lines")
        } catch {
            print("Error parsing subway_shapes.json: \(error)")
        }
    }

    /// Get shape data for a specific line
    func shapes(for lineId: String) -> SubwayLineShape? {
        if !isLoaded { loadShapes() }
        return lineShapes[lineId]
    }

    /// Get all line shapes
    func allShapes() -> [SubwayLineShape] {
        if !isLoaded { loadShapes() }
        return Array(lineShapes.values)
    }

    /// Get shapes for multiple lines
    func shapes(for lineIds: [String]) -> [SubwayLineShape] {
        if !isLoaded { loadShapes() }
        return lineIds.compactMap { lineShapes[$0] }
    }
}
