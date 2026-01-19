import Foundation
import SwiftData
import CoreLocation

/// MetroLog NYC - Station model using SwiftData for persistence
@Model
final class Station {
    /// Unique identifier for the station
    var id: UUID

    /// Station name (e.g., "Times Sq-42 St")
    var name: String

    /// Subway lines serving this station (e.g., ["1", "2", "3", "7", "N", "Q", "R", "W", "S"])
    var lines: [String]

    /// Station latitude
    var latitude: Double

    /// Station longitude
    var longitude: Double

    /// Borough where the station is located (stored as raw value for SwiftData)
    private var boroughRawValue: String

    /// Type-safe borough accessor
    var borough: Borough {
        get { Borough(rawValue: boroughRawValue) ?? .manhattan }
        set { boroughRawValue = newValue.rawValue }
    }

    /// Type-safe subway lines accessor
    var subwayLines: [SubwayLine] {
        lines.compactMap { SubwayLine.from($0) }
    }

    /// Whether the user has visited this station
    var isVisited: Bool

    /// Date when the station was marked as visited
    var visitedDate: Date?

    /// Optional station complex this station belongs to
    var complex: StationComplex?

    init(
        id: UUID = UUID(),
        name: String,
        lines: [SubwayLine],
        latitude: Double,
        longitude: Double,
        borough: Borough,
        isVisited: Bool = false,
        visitedDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.lines = lines.map { $0.rawValue }
        self.latitude = latitude
        self.longitude = longitude
        self.boroughRawValue = borough.rawValue
        self.isVisited = isVisited
        self.visitedDate = visitedDate
    }

    /// CLLocationCoordinate2D for MapKit
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Toggle visited status
    func toggleVisited() {
        isVisited.toggle()
        visitedDate = isVisited ? Date() : nil
    }

    /// Lines formatted as a string for display
    var linesDescription: String {
        lines.joined(separator: " ")
    }
}

// MARK: - Borough Enum
enum Borough: String, CaseIterable, Identifiable {
    case manhattan = "Manhattan"
    case brooklyn = "Brooklyn"
    case queens = "Queens"
    case bronx = "Bronx"
    case statenIsland = "Staten Island"

    var id: String { rawValue }
}

// MARK: - Filter Options
enum StationFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case visited = "Visited"
    case unvisited = "Unvisited"

    var id: String { rawValue }
}

enum StationSort: String, CaseIterable, Identifiable {
    case name = "Name"
    case borough = "Borough"
    case recentlyVisited = "Recently Visited"

    var id: String { rawValue }
}
