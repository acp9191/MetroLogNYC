import SwiftUI
import SwiftData

/// Detail view showing all stations for a specific subway line
struct LineDetailView: View {
    let line: String
    @Query private var stations: [Station]
    @State private var selectedStation: Station?

    private var lineStations: [Station] {
        stations.filter { $0.lines.contains(line) }
            .sorted { $0.name < $1.name }
    }

    private var visitedCount: Int {
        lineStations.filter { $0.isVisited }.count
    }

    private var progress: Double {
        guard !lineStations.isEmpty else { return 0 }
        return Double(visitedCount) / Double(lineStations.count)
    }

    private var lineName: String {
        switch line {
        case "1", "2", "3": return "\(line) Train - Broadway-Seventh Avenue"
        case "4", "5", "6": return "\(line) Train - Lexington Avenue"
        case "7": return "7 Train - Flushing"
        case "A", "C", "E": return "\(line) Train - Eighth Avenue"
        case "B", "D", "F", "M": return "\(line) Train - Sixth Avenue"
        case "G": return "G Train - Crosstown"
        case "J", "Z": return "\(line) Train - Nassau Street"
        case "L": return "L Train - Canarsie"
        case "N", "Q", "R", "W": return "\(line) Train - Broadway"
        case "GS": return "42 St Shuttle"
        case "FS": return "Franklin Av Shuttle"
        case "RS": return "Rockaway Park Shuttle"
        case "SIR": return "Staten Island Railway"
        default: return "\(line) Train"
        }
    }

    private var toolbarTitle: String {
        switch line {
        case "GS": return "42 St Shuttle"
        case "FS": return "Franklin Shuttle"
        case "RS": return "Rockaway Shuttle"
        case "SIR": return "SIR"
        default: return "\(line) Train"
        }
    }

    private var officialLineName: String {
        switch line {
        case "1": return "Broadway–7 Avenue Local"
        case "2": return "7 Avenue Express"
        case "3": return "7 Avenue Express"
        case "4": return "Lexington Avenue Express"
        case "5": return "Lexington Avenue Express"
        case "6": return "Lexington Avenue Local"
        case "7": return "Flushing Local"
        case "A": return "8 Avenue Express"
        case "B": return "6 Avenue Express"
        case "C": return "8 Avenue Local"
        case "D": return "6 Avenue Express"
        case "E": return "8 Avenue Local"
        case "F": return "Queens Blvd Express/6 Av Local"
        case "G": return "Brooklyn–Queens Crosstown"
        case "J": return "Nassau Street Local"
        case "L": return "14 Street–Canarsie Local"
        case "M": return "Queens Blvd/6 Av/Myrtle Av Local"
        case "N": return "Broadway Express"
        case "Q": return "Broadway Express"
        case "R": return "Broadway Local"
        case "W": return "Broadway Local"
        case "Z": return "Nassau Street Express"
        case "GS": return "42 Street Shuttle"
        case "FS": return "Franklin Avenue Shuttle"
        case "RS": return "Rockaway Park Shuttle"
        case "SIR": return "Staten Island Railway"
        default: return ""
        }
    }

    // Group stations by borough
    private var stationsByBorough: [(borough: Borough, stations: [Station])] {
        let grouped = Dictionary(grouping: lineStations) { $0.borough }
        return Borough.allCases.compactMap { borough in
            guard let stations = grouped[borough], !stations.isEmpty else { return nil }
            return (borough, stations.sorted { $0.name < $1.name })
        }
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

            // Stations grouped by borough
            ForEach(stationsByBorough, id: \.borough) { group in
                Section(header: Text(group.borough.rawValue)) {
                    ForEach(group.stations) { station in
                        LineStationRow(station: station, currentLine: line)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedStation = station
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    station.toggleVisited()
                                } label: {
                                    Label(
                                        station.isVisited ? "Unvisit" : "Visit",
                                        systemImage: station.isVisited ? "xmark.circle" : "checkmark.circle"
                                    )
                                }
                                .tint(station.isVisited ? .orange : .blue)
                            }
                    }
                }
            }
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
        .sheet(item: $selectedStation) { station in
            StationDetailView(station: station)
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

                    Text("\(visitedCount) of \(totalCount) stations")
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
                Text("\(Int(progress * 100))%")
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

// MARK: - Line Station Row
struct LineStationRow: View {
    @Bindable var station: Station
    let currentLine: String

    var body: some View {
        HStack(spacing: 12) {
            // Visited indicator
            Image(systemName: station.isVisited ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(station.isVisited ? .blue : .gray.opacity(0.5))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        station.toggleVisited()
                    }
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.body)
                    .foregroundStyle(station.isVisited ? .primary : .primary)

                // Show other lines at this station (excluding current line)
                let otherLines = station.lines.filter { $0 != currentLine }
                if !otherLines.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(otherLines.prefix(6), id: \.self) { line in
                            LineBadge(line: line, size: 18)
                        }
                        if otherLines.count > 6 {
                            Text("+\(otherLines.count - 6)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Spacer()

            if station.isVisited {
                if let date = station.visitedDate {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        LineDetailView(line: "1")
    }
    .modelContainer(for: Station.self, inMemory: true)
}
