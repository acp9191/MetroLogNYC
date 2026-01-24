import SwiftUI
import SwiftData

/// Main list view displaying subway stations grouped by complex
struct StationListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Station.name) private var stations: [Station]
    @Query(sort: \StationComplex.name) private var complexes: [StationComplex]

    @State private var searchText = ""
    @State private var selectedBorough: Borough? = nil
    @State private var selectedLine: String? = nil
    @State private var visitedFilter: StationFilter = .all
    @State private var sortOption: StationSort = .name
    @State private var selectedItem: StationDisplayItem?
    @State private var showingFilters = false

    /// Create display items from stations and complexes
    private var displayItems: [StationDisplayItem] {
        StationDisplayItem.createDisplayItems(stations: stations, complexes: complexes)
    }

    private var filteredItems: [StationDisplayItem] {
        var result = displayItems

        // Search filter
        if !searchText.isEmpty {
            result = result.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.lines.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                item.borough.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Borough filter
        if let borough = selectedBorough {
            result = result.filter { $0.borough == borough }
        }

        // Line filter
        if let line = selectedLine {
            result = result.filter { $0.lines.contains(line) }
        }

        // Visited filter
        switch visitedFilter {
        case .all:
            break
        case .visited:
            result = result.filter { $0.isVisited }
        case .unvisited:
            result = result.filter { !$0.isVisited }
        }

        // Sorting
        switch sortOption {
        case .name:
            result.sort { $0.name < $1.name }
        case .borough:
            result.sort { ($0.borough.rawValue, $0.name) < ($1.borough.rawValue, $1.name) }
        case .recentlyVisited:
            result.sort { item1, item2 in
                let date1 = item1.lastVisitedDate ?? .distantPast
                let date2 = item2.lastVisitedDate ?? .distantPast
                return date1 > date2
            }
        }

        return result
    }

    /// Count of unique locations (complexes + standalone stations)
    private var totalLocationCount: Int {
        displayItems.count
    }

    /// Count of visited locations
    private var visitedLocationCount: Int {
        displayItems.filter { $0.isVisited }.count
    }

    /// Progress percentage
    private var progress: Double {
        guard totalLocationCount > 0 else { return 0 }
        return Double(visitedLocationCount) / Double(totalLocationCount)
    }

    // Lines ordered by trunk line (MTA standard grouping)
    private let allLines = [
        "1", "2", "3",           // Broadway-7th Ave (red)
        "4", "5", "6",           // Lexington Ave (green)
        "7",                     // Flushing (purple)
        "A", "C", "E",           // 8th Ave (blue)
        "B", "D", "F", "M",      // 6th Ave (orange)
        "G",                     // Crosstown (lime)
        "J", "Z",                // Nassau St (brown)
        "L",                     // Canarsie (gray)
        "N", "Q", "R", "W",      // Broadway (yellow)
        "GS", "FS", "RS",        // Shuttles
        "SIR"                    // Staten Island
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Header
                ProgressHeader(
                    visitedCount: visitedLocationCount,
                    totalCount: totalLocationCount,
                    progress: progress
                )

                // Line Filter Bar
                LineFilterBar(selectedLine: $selectedLine, allLines: allLines)

                // Active Filter Chips (borough and status only)
                if selectedBorough != nil || visitedFilter != .all {
                    FilterChipsView(
                        selectedBorough: $selectedBorough,
                        selectedLine: .constant(nil),
                        visitedFilter: $visitedFilter
                    )
                }

                // Station List
                List {
                    ForEach(filteredItems) { item in
                        StationDisplayRowView(item: item) {
                            item.toggleVisited()
                        }
                        .onTapGesture {
                            selectedItem = item
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                item.toggleVisited()
                            } label: {
                                Label(
                                    item.isVisited ? "Unvisit" : "Visit",
                                    systemImage: item.isVisited ? "xmark.circle" : "checkmark.circle"
                                )
                            }
                            .tint(item.isVisited ? .orange : .blue)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Stops")
            .searchable(text: $searchText, prompt: "Search stops, lines, or boroughs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        // Sort Options
                        Section("Sort By") {
                            ForEach(StationSort.allCases) { sort in
                                Button {
                                    sortOption = sort
                                } label: {
                                    HStack {
                                        Text(sort.rawValue)
                                        if sortOption == sort {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }

                        // Filter by Visited Status
                        Section("Filter by Status") {
                            ForEach(StationFilter.allCases) { filter in
                                Button {
                                    visitedFilter = filter
                                } label: {
                                    HStack {
                                        Text(filter.rawValue)
                                        if visitedFilter == filter {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }

                        // Filter by Borough
                        Section("Filter by Borough") {
                            Button("All Boroughs") {
                                selectedBorough = nil
                            }
                            ForEach(Borough.allCases) { borough in
                                Button {
                                    selectedBorough = borough
                                } label: {
                                    HStack {
                                        Text(borough.rawValue)
                                        if selectedBorough == borough {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                ComplexDetailView(item: item)
            }
        }
    }
}

// MARK: - Progress Header
struct ProgressHeader: View {
    let visitedCount: Int
    let totalCount: Int
    let progress: Double

    /// Shows at least 1% if any progress has been made
    private var progressPercent: Int {
        let percent = Int(progress * 100)
        if visitedCount > 0 && percent == 0 {
            return 1
        }
        return percent
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(visitedCount) of \(totalCount)")
                        .font(.headline)
                    Text("locations visited")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(progressPercent)%")
                    .font(.title2.bold())
                    .foregroundStyle(.blue)
            }

            ProgressView(value: progress)
                .tint(.blue)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }
}

// MARK: - Filter Chips View
struct FilterChipsView: View {
    @Binding var selectedBorough: Borough?
    @Binding var selectedLine: String?
    @Binding var visitedFilter: StationFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let borough = selectedBorough {
                    FilterChip(text: borough.rawValue) {
                        selectedBorough = nil
                    }
                }

                if let line = selectedLine {
                    FilterChip(text: "Line \(line)") {
                        selectedLine = nil
                    }
                }

                if visitedFilter != .all {
                    FilterChip(text: visitedFilter.rawValue) {
                        visitedFilter = .all
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.secondarySystemBackground))
    }
}

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.2))
        .foregroundStyle(.blue)
        .clipShape(Capsule())
    }
}

// MARK: - Line Filter Bar
struct LineFilterBar: View {
    @Binding var selectedLine: String?
    let allLines: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                // All lines button
                Button {
                    selectedLine = nil
                } label: {
                    Text("All")
                        .font(.caption.bold())
                        .foregroundStyle(selectedLine == nil ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedLine == nil ? Color.blue : Color(.tertiarySystemBackground))
                        .clipShape(Capsule())
                }

                ForEach(allLines, id: \.self) { line in
                    Button {
                        selectedLine = selectedLine == line ? nil : line
                    } label: {
                        LineBadge(line: line, size: 28)
                            .opacity(selectedLine == nil || selectedLine == line ? 1.0 : 0.4)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.secondarySystemBackground))
    }
}

#Preview {
    StationListView()
        .modelContainer(for: [Station.self, StationComplex.self], inMemory: true)
}
