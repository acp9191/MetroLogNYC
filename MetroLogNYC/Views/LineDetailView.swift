import SwiftUI
import SwiftData

/// Detail view showing all stations for a specific subway line
struct LineDetailView: View {
    let line: String
    @Query private var stations: [Station]
    @Query private var complexes: [StationComplex]
    @State private var selectedItem: StationDisplayItem?

    private var lineStations: [Station] {
        stations.filter { $0.lines.contains(line) }
    }

    /// Stations sorted by route order
    private var orderedStations: [Station] {
        let route = LineRouteData.route(for: line)
        return stationsFromNames(route.mainLine, excludeUsed: true)
    }

    /// Get the best matching station from duplicates based on proximity to previous station
    private func bestMatch(from candidates: [Station], previousStation: Station?) -> Station? {
        guard !candidates.isEmpty else { return nil }
        guard candidates.count > 1, let prev = previousStation else {
            return candidates.first
        }

        // Pick the candidate closest to the previous station
        return candidates.min { station1, station2 in
            let dist1 = distance(from: prev, to: station1)
            let dist2 = distance(from: prev, to: station2)
            return dist1 < dist2
        }
    }

    /// Calculate rough distance between two stations
    private func distance(from s1: Station, to s2: Station) -> Double {
        let latDiff = s1.latitude - s2.latitude
        let lonDiff = s1.longitude - s2.longitude
        return latDiff * latDiff + lonDiff * lonDiff
    }

    /// Route data for branching display
    private var routeData: LineRouteData.Route {
        LineRouteData.route(for: line)
    }

    private var visitedCount: Int {
        lineStations.filter { $0.isVisited }.count
    }

    private var progress: Double {
        guard !lineStations.isEmpty else { return 0 }
        return Double(visitedCount) / Double(lineStations.count)
    }

    private struct LineNameInfo {
        let displayName: String
        let toolbarTitle: String
        let officialName: String
    }

    private static let lineNames: [String: LineNameInfo] = [
        "1":   .init(displayName: "1 Train - Broadway-Seventh Avenue",  toolbarTitle: "1 Train",          officialName: "Broadway–7 Avenue Local"),
        "2":   .init(displayName: "2 Train - Broadway-Seventh Avenue",  toolbarTitle: "2 Train",          officialName: "7 Avenue Express"),
        "3":   .init(displayName: "3 Train - Broadway-Seventh Avenue",  toolbarTitle: "3 Train",          officialName: "7 Avenue Express"),
        "4":   .init(displayName: "4 Train - Lexington Avenue",         toolbarTitle: "4 Train",          officialName: "Lexington Avenue Express"),
        "5":   .init(displayName: "5 Train - Lexington Avenue",         toolbarTitle: "5 Train",          officialName: "Lexington Avenue Express"),
        "6":   .init(displayName: "6 Train - Lexington Avenue",         toolbarTitle: "6 Train",          officialName: "Lexington Avenue Local"),
        "7":   .init(displayName: "7 Train - Flushing",                 toolbarTitle: "7 Train",          officialName: "Flushing Local"),
        "A":   .init(displayName: "A Train - Eighth Avenue",            toolbarTitle: "A Train",          officialName: "8 Avenue Express"),
        "B":   .init(displayName: "B Train - Sixth Avenue",             toolbarTitle: "B Train",          officialName: "6 Avenue Express"),
        "C":   .init(displayName: "C Train - Eighth Avenue",            toolbarTitle: "C Train",          officialName: "8 Avenue Local"),
        "D":   .init(displayName: "D Train - Sixth Avenue",             toolbarTitle: "D Train",          officialName: "6 Avenue Express"),
        "E":   .init(displayName: "E Train - Eighth Avenue",            toolbarTitle: "E Train",          officialName: "8 Avenue Local"),
        "F":   .init(displayName: "F Train - Sixth Avenue",             toolbarTitle: "F Train",          officialName: "Queens Blvd Express/6 Av Local"),
        "G":   .init(displayName: "G Train - Crosstown",                toolbarTitle: "G Train",          officialName: "Brooklyn–Queens Crosstown"),
        "J":   .init(displayName: "J Train - Nassau Street",            toolbarTitle: "J Train",          officialName: "Nassau Street Local"),
        "Z":   .init(displayName: "Z Train - Nassau Street",            toolbarTitle: "Z Train",          officialName: "Nassau Street Express"),
        "L":   .init(displayName: "L Train - Canarsie",                 toolbarTitle: "L Train",          officialName: "14 Street–Canarsie Local"),
        "M":   .init(displayName: "M Train - Sixth Avenue",             toolbarTitle: "M Train",          officialName: "Queens Blvd/6 Av/Myrtle Av Local"),
        "N":   .init(displayName: "N Train - Broadway",                 toolbarTitle: "N Train",          officialName: "Broadway Express"),
        "Q":   .init(displayName: "Q Train - Broadway",                 toolbarTitle: "Q Train",          officialName: "Broadway Express"),
        "R":   .init(displayName: "R Train - Broadway",                 toolbarTitle: "R Train",          officialName: "Broadway Local"),
        "W":   .init(displayName: "W Train - Broadway",                 toolbarTitle: "W Train",          officialName: "Broadway Local"),
        "GS":  .init(displayName: "42 St Shuttle",                      toolbarTitle: "42 St Shuttle",    officialName: "42 Street Shuttle"),
        "FS":  .init(displayName: "Franklin Av Shuttle",                toolbarTitle: "Franklin Shuttle", officialName: "Franklin Avenue Shuttle"),
        "RS":  .init(displayName: "Rockaway Park Shuttle",              toolbarTitle: "Rockaway Shuttle", officialName: "Rockaway Park Shuttle"),
        "SIR": .init(displayName: "Staten Island Railway",              toolbarTitle: "SIR",              officialName: "Staten Island Railway"),
    ]

    private var lineInfo: LineNameInfo {
        Self.lineNames[line] ?? .init(displayName: "\(line) Train", toolbarTitle: "\(line) Train", officialName: "")
    }

    private var lineName: String { lineInfo.displayName }
    private var toolbarTitle: String { lineInfo.toolbarTitle }
    private var officialLineName: String { lineInfo.officialName }

    /// Get stations for a branch by name
    private func stationsForBranch(_ branch: LineRouteData.Branch) -> [Station] {
        return stationsFromNames(branch.stations, excludeUsed: true)
    }

    /// The color for this subway line
    private var lineColor: Color {
        SubwayLine.from(line)?.color ?? .gray
    }

    /// Group stations by borough while maintaining route order
    private func stationsByBorough(_ stations: [Station]) -> [(borough: Borough, stations: [Station])] {
        var result: [(borough: Borough, stations: [Station])] = []
        var currentBorough: Borough?
        var currentStations: [Station] = []

        for station in stations {
            if station.borough != currentBorough {
                if let borough = currentBorough, !currentStations.isEmpty {
                    result.append((borough, currentStations))
                }
                currentBorough = station.borough
                currentStations = [station]
            } else {
                currentStations.append(station)
            }
        }

        if let borough = currentBorough, !currentStations.isEmpty {
            result.append((borough, currentStations))
        }

        return result
    }

    /// Determine the position of a station in the tree
    /// - Parameters:
    ///   - globalIndex: Index in the full station list
    ///   - totalCount: Total number of stations
    ///   - isFirstInSection: Whether this is the first station in the borough section
    ///   - isLastInSection: Whether this is the last station in the borough section
    ///   - isBranchPoint: Whether this station is where a branch connects
    private func stationPosition(
        globalIndex: Int,
        totalCount: Int,
        isFirstInSection: Bool,
        isLastInSection: Bool,
        isBranchPoint: Bool
    ) -> StationPosition {
        if isBranchPoint {
            return .branchPoint
        }
        // First station of entire line
        if globalIndex == 0 {
            return .first
        }
        // Last station of entire line
        if globalIndex == totalCount - 1 {
            return .last
        }
        // Everything else is middle (line continues through)
        return .middle
    }

    /// Check if a station is a branch point
    private func isBranchPoint(_ station: Station) -> Bool {
        routeData.branches.contains { $0.branchPoint == station.name }
    }

    /// Get stations from name list, using proximity to disambiguate duplicates
    /// - Parameters:
    ///   - names: List of station names in route order
    ///   - excludeUsed: If true, each station can only be used once (for handling duplicate names like "7 Av")
    private func stationsFromNames(_ names: [String], excludeUsed: Bool = false) -> [Station] {
        let stationsByName = Dictionary(grouping: lineStations) { $0.name }
        var result: [Station] = []
        var usedStationIds: Set<UUID> = []

        for name in names {
            guard var candidates = stationsByName[name] else { continue }

            // Filter out already-used stations if needed
            if excludeUsed {
                candidates = candidates.filter { !usedStationIds.contains($0.id) }
            }

            if let match = bestMatch(from: candidates, previousStation: result.last) {
                result.append(match)
                usedStationIds.insert(match.id)
            }
        }

        return result
    }

    // MARK: - Tree Style Content

    @ViewBuilder
    private var treeStyleContent: some View {
        if routeData.branches.isEmpty {
            // No branches - simple tree view
            simpleTreeContent
        } else if let bottomBranch = routeData.bottomBranches.first {
            // Has bottom branch (like A train) - show git-style split
            gitStyleBottomBranchContent(bottomBranch)
        } else if let topBranch = routeData.topBranches.first {
            // Has top branch (like 5 train) - show git-style merge
            gitStyleTopBranchContent(topBranch)
        } else {
            simpleTreeContent
        }
    }

    /// Simple tree for lines without branches
    @ViewBuilder
    private var simpleTreeContent: some View {
        let allStations = orderedStations
        let boroughGroups = stationsByBorough(allStations)

        ForEach(Array(boroughGroups.enumerated()), id: \.element.borough) { groupIndex, group in
            Section(header: Text(group.borough.rawValue)) {
                ForEach(Array(group.stations.enumerated()), id: \.element.id) { localIndex, station in
                    let currentGlobalIndex = boroughGroups[0..<groupIndex].reduce(0) { $0 + $1.stations.count } + localIndex
                    let position = stationPosition(
                        globalIndex: currentGlobalIndex,
                        totalCount: allStations.count,
                        isFirstInSection: localIndex == 0,
                        isLastInSection: localIndex == group.stations.count - 1,
                        isBranchPoint: false
                    )
                    treeStationRow(station: station, position: position, isBranch: false)
                }
            }
        }
    }

    /// Git-style tree for lines with a bottom branch (split, like A train)
    /// Main line on left, branch indented to right at split point, then main line continues
    @ViewBuilder
    private func gitStyleBottomBranchContent(_ branch: LineRouteData.Branch) -> some View {
        // Stations before the split (up to and including branch point)
        let stationsBeforeSplit = stationsFromNames(routeData.stationsBeforeBranch(branch))
        let mainContinuation = stationsFromNames(routeData.stationsAfterBranch(branch))
        let branchStations = stationsForBranch(branch)

        // Group stations before split by borough
        let boroughGroupsBefore = stationsByBorough(stationsBeforeSplit)

        ForEach(Array(boroughGroupsBefore.enumerated()), id: \.element.borough) { groupIndex, group in
            Section(header: Text(group.borough.rawValue)) {
                ForEach(Array(group.stations.enumerated()), id: \.element.id) { localIndex, station in
                    let currentGlobalIndex = boroughGroupsBefore[0..<groupIndex].reduce(0) { $0 + $1.stations.count } + localIndex
                    let isLast = (groupIndex == boroughGroupsBefore.count - 1) && (localIndex == group.stations.count - 1)
                    let position: StationPosition = currentGlobalIndex == 0 ? .first : (isLast ? .branchPoint : .middle)
                    treeStationRow(station: station, position: position, isBranch: false)
                }
            }
        }

        // Ozone Park branch (indented, splits off to the right with main line continuing on left)
        if !mainContinuation.isEmpty {
            Section(header: Text("To \(mainContinuation.last?.name ?? "")")) {
                ForEach(Array(mainContinuation.enumerated()), id: \.element.id) { index, station in
                    let position: StationPosition = index == mainContinuation.count - 1 ? .last : (index == 0 ? .first : .middle)
                    treeStationRow(station: station, position: position, isBranch: true, showMainLineContinuation: true)
                }
            }
        }

        // Far Rockaway branch continues as the main line visually (connects from Rockaway Blvd)
        if !branchStations.isEmpty {
            let branchBoroughs = stationsByBorough(branchStations)
            ForEach(Array(branchBoroughs.enumerated()), id: \.element.borough) { groupIndex, group in
                let sectionTitle = groupIndex == 0 ? "To \(branch.name)" : group.borough.rawValue
                Section(header: Text(sectionTitle)) {
                    ForEach(Array(group.stations.enumerated()), id: \.element.id) { localIndex, station in
                        let isLast = (groupIndex == branchBoroughs.count - 1) && (localIndex == group.stations.count - 1)
                        let position: StationPosition = isLast ? .last : .middle
                        treeStationRow(station: station, position: position, isBranch: false)
                    }
                }
            }
        }
    }

    /// Git-style tree for lines with a top branch (merge, like 5 train)
    /// Branch shown first indented, then merges into main line
    @ViewBuilder
    private func gitStyleTopBranchContent(_ branch: LineRouteData.Branch) -> some View {
        let branchStations = stationsForBranch(branch)

        // Branch stations (shown first, indented)
        if !branchStations.isEmpty {
            let branchBoroughs = stationsByBorough(branchStations)
            ForEach(Array(branchBoroughs.enumerated()), id: \.element.borough) { groupIndex, group in
                Section(header: Text("\(branch.name) Branch - \(group.borough.rawValue)")) {
                    ForEach(Array(group.stations.enumerated()), id: \.element.id) { localIndex, station in
                        let isFirst = groupIndex == 0 && localIndex == 0
                        let isLast = groupIndex == branchBoroughs.count - 1 && localIndex == group.stations.count - 1
                        let position: StationPosition = isFirst ? .first : (isLast ? .last : .middle)
                        treeStationRow(station: station, position: position, isBranch: true)
                    }
                }
            }
        }

        // Main line stations (branch merges in at first station)
        let allStations = orderedStations
        let boroughGroups = stationsByBorough(allStations)

        ForEach(Array(boroughGroups.enumerated()), id: \.element.borough) { groupIndex, group in
            Section(header: Text(group.borough.rawValue)) {
                ForEach(Array(group.stations.enumerated()), id: \.element.id) { localIndex, station in
                    let currentGlobalIndex = boroughGroups[0..<groupIndex].reduce(0) { $0 + $1.stations.count } + localIndex
                    let isFirst = currentGlobalIndex == 0
                    let isLast = currentGlobalIndex == allStations.count - 1
                    let position: StationPosition = isFirst ? .branchPoint : (isLast ? .last : .middle)
                    treeStationRow(station: station, position: position, isBranch: false)
                }
            }
        }
    }

    /// Reusable tree station row
    @ViewBuilder
    private func treeStationRow(station: Station, position: StationPosition, isBranch: Bool, showMainLineContinuation: Bool = false) -> some View {
        TreeStationRow(
            station: station,
            currentLine: line,
            position: position,
            isBranch: isBranch,
            lineColor: lineColor,
            showMainLineContinuation: showMainLineContinuation,
            onTap: {
                // Navigate to complex if station is part of one, otherwise create virtual complex
                if let complex = station.complex {
                    selectedItem = StationDisplayItem(complex: complex)
                } else {
                    selectedItem = StationDisplayItem(station: station)
                }
            }
        )
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    var body: some View {
        List {
            // Progress Header Section
            Section {
                LineProgressHeader(
                    line: line,
                    officialName: officialLineName,
                    visitedCount: visitedCount,
                    totalCount: lineStations.count,
                    progress: progress
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            // Tree-style view for all lines
            treeStyleContent
        }
        .listStyle(.insetGrouped)
        .navigationTitle(lineName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    LineBadge(line: line, size: 28)
                    Text(toolbarTitle)
                        .font(.headline)
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            ComplexDetailView(item: item)
        }
    }
}

// MARK: - Line Progress Header
struct LineProgressHeader: View {
    let line: String
    let officialName: String
    let visitedCount: Int
    let totalCount: Int
    let progress: Double

    private var lineColor: Color {
        SubwayLine.from(line)?.color ?? .gray
    }

    private var progressPercent: Int {
        progress.displayPercent(visited: visitedCount)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Large line badge
                LineBadge(line: line, size: 56)

                VStack(alignment: .leading, spacing: 4) {
                    // Official line name
                    Text(officialName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("\(visitedCount) of \(totalCount) stops")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))

                            Capsule()
                                .fill(lineColor)
                                .frame(width: max(1, geometry.size.width * progress))
                        }
                    }
                    .frame(height: 8)
                }

                Spacer()

                // Percentage
                Text("\(progressPercent)%")
                    .font(.title2.bold())
                    .foregroundStyle(lineColor)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        LineDetailView(line: "1")
    }
    .modelContainer(for: Station.self, inMemory: true)
}
