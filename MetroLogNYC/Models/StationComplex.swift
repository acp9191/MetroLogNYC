import Foundation
import SwiftData

/// Represents a station complex - a group of related stations that share connections
/// MTA recognizes 32 multi-station complexes across the subway system
@Model
final class StationComplex {
    /// Unique identifier for the complex
    var id: UUID

    /// Complex name (e.g., "Times Sq-42 St / 42 St-Port Authority Bus Terminal")
    var name: String

    /// Stations belonging to this complex
    @Relationship(deleteRule: .nullify, inverse: \Station.complex)
    var stations: [Station]

    /// Borough where the complex is located (stored as raw value for SwiftData)
    private var boroughRawValue: String

    /// Type-safe borough accessor
    var borough: Borough {
        get { Borough(rawValue: boroughRawValue) ?? .manhattan }
        set { boroughRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        borough: Borough,
        stations: [Station] = []
    ) {
        self.id = id
        self.name = name
        self.boroughRawValue = borough.rawValue
        self.stations = stations
    }

    /// All unique lines serving this complex
    var allLines: [String] {
        let allLineArrays = stations.flatMap { $0.lines }
        return Array(Set(allLineArrays)).sorted()
    }

    /// Lines formatted as a string for display
    var linesDescription: String {
        allLines.joined(separator: " ")
    }

}
