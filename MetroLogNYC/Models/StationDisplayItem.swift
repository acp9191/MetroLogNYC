import Foundation
import SwiftUI
import SwiftData

/// A unified display item that represents either a station complex or a standalone station
/// This provides a consistent interface for the list view regardless of whether
/// stations are part of a complex or not
struct StationDisplayItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let borough: Borough
    let lines: [String]
    let isComplex: Bool

    // For complexes
    let complex: StationComplex?
    let stations: [Station]

    // For standalone stations
    let station: Station?

    /// Create a display item from a station complex
    init(complex: StationComplex) {
        self.id = complex.id
        self.name = complex.name
        self.borough = complex.borough
        self.lines = complex.allLines
        self.isComplex = true
        self.complex = complex
        self.stations = complex.stations
        self.station = nil
    }

    /// Create a display item from a standalone station (not part of any complex)
    init(station: Station) {
        self.id = station.id
        self.name = station.name
        self.borough = station.borough
        self.lines = station.lines
        self.isComplex = false
        self.complex = nil
        self.stations = [station]
        self.station = station
    }

    // MARK: - Visit Status

    /// Whether the item is fully visited (all stations for complex, or the single station)
    var isVisited: Bool {
        stations.allSatisfy { $0.isVisited }
    }

    /// Whether the item is partially visited (only relevant for complexes)
    var isPartiallyVisited: Bool {
        guard isComplex else { return false }
        let visitedCount = stations.filter { $0.isVisited }.count
        return visitedCount > 0 && visitedCount < stations.count
    }

    /// Number of visited stations
    var visitedCount: Int {
        stations.filter { $0.isVisited }.count
    }

    /// Total number of stations
    var stationCount: Int {
        stations.count
    }

    /// Most recent visit date among all stations
    var lastVisitedDate: Date? {
        stations.compactMap { $0.visitedDate }.max()
    }

    // MARK: - Actions

    /// Toggle visited status for all stations in this item
    func toggleVisited() {
        let shouldMarkVisited = !isVisited
        for station in stations {
            if station.isVisited != shouldMarkVisited {
                station.toggleVisited()
            }
        }
    }

    /// Mark all stations as visited
    func markVisited() {
        for station in stations where !station.isVisited {
            station.toggleVisited()
        }
    }

    /// Mark all stations as unvisited
    func markUnvisited() {
        for station in stations where station.isVisited {
            station.toggleVisited()
        }
    }

    // MARK: - Hashable

    static func == (lhs: StationDisplayItem, rhs: StationDisplayItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Factory

    /// Creates display items from stations and complexes
    /// Stations that belong to a complex are grouped under the complex
    /// Standalone stations become their own display items
    static func createDisplayItems(
        stations: [Station],
        complexes: [StationComplex]
    ) -> [StationDisplayItem] {
        var items: [StationDisplayItem] = []
        var stationsInComplexes = Set<UUID>()

        // Add complexes
        for complex in complexes {
            // Only add complexes that have stations
            guard !complex.stations.isEmpty else { continue }
            items.append(StationDisplayItem(complex: complex))
            // Track which stations are in complexes
            for station in complex.stations {
                stationsInComplexes.insert(station.id)
            }
        }

        // Add standalone stations (those not in any complex)
        for station in stations {
            if !stationsInComplexes.contains(station.id) {
                items.append(StationDisplayItem(station: station))
            }
        }

        return items
    }
}
