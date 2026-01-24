import SwiftUI
import SwiftData

/// Home view displaying overall progress and line cards
struct HomeView: View {
    @Query private var stations: [Station]
    @Query private var complexes: [StationComplex]
    @State private var selectedLine: String?

    /// All locations (complexes + standalone stations as virtual complexes)
    private var displayItems: [StationDisplayItem] {
        StationDisplayItem.createDisplayItems(stations: stations, complexes: complexes)
    }

    private var visitedCount: Int {
        displayItems.filter { $0.isVisited }.count
    }

    private var totalCount: Int {
        displayItems.count
    }

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(visitedCount) / Double(totalCount)
    }

    // All subway lines grouped by color/family
    private let lineGroups: [(name: String, lines: [String])] = [
        ("Broadway-Seventh Avenue", ["1", "2", "3"]),
        ("Lexington Avenue", ["4", "5", "6"]),
        ("Flushing", ["7"]),
        ("Eighth Avenue", ["A", "C", "E"]),
        ("Sixth Avenue", ["B", "D", "F", "M"]),
        ("Crosstown", ["G"]),
        ("Canarsie", ["L"]),
        ("Nassau Street", ["J", "Z"]),
        ("Broadway", ["N", "Q", "R", "W"]),
        ("Shuttles", ["S"]),
        ("Staten Island", ["SIR"])
    ]

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
            ScrollView {
                VStack(spacing: 24) {
                    // Subtitle
                    Text("Track your subway journey")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, -8)

                    // Hero Progress Section
                    ProgressHeroView(
                        visitedCount: visitedCount,
                        totalCount: totalCount,
                        progress: progress
                    )
                    .padding(.horizontal)

                    // Lines Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Lines")
                            .font(.title2.bold())
                            .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(allLines, id: \.self) { line in
                                NavigationLink(destination: LineDetailView(line: line)) {
                                    LineCard(line: line, displayItems: displayItems)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Borough Progress Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Boroughs")
                            .font(.title2.bold())
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            ForEach(Borough.allCases) { borough in
                                BoroughCard(borough: borough, displayItems: displayItems)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("MetroLog NYC")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Progress Hero View
struct ProgressHeroView: View {
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
        VStack(spacing: 20) {
            // Circular progress
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 16)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.5), value: progress)

                VStack(spacing: 4) {
                    Text("\(visitedCount)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                    Text("of \(totalCount) stops")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 180, height: 180)

            // Percentage badge
            Text("\(progressPercent)% Complete")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Line Card
struct LineCard: View {
    let line: String
    let displayItems: [StationDisplayItem]

    private var lineItems: [StationDisplayItem] {
        displayItems.filter { $0.lines.contains(line) }
    }

    private var visitedCount: Int {
        lineItems.filter { $0.isVisited }.count
    }

    private var progress: Double {
        guard !lineItems.isEmpty else { return 0 }
        return Double(visitedCount) / Double(lineItems.count)
    }

    var body: some View {
        VStack(spacing: 8) {
            LineBadge(line: line, size: 44)

            Text("\(visitedCount)/\(lineItems.count)")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))

                    Capsule()
                        .fill(Color.blue)
                        .frame(width: max(1, geometry.size.width * progress))
                }
            }
            .frame(height: 4)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Borough Card
struct BoroughCard: View {
    let borough: Borough
    let displayItems: [StationDisplayItem]

    private var boroughItems: [StationDisplayItem] {
        displayItems.filter { $0.borough == borough }
    }

    private var visitedCount: Int {
        boroughItems.filter { $0.isVisited }.count
    }

    private var progress: Double {
        guard !boroughItems.isEmpty else { return 0 }
        return Double(visitedCount) / Double(boroughItems.count)
    }

    private var icon: String {
        switch borough {
        case .manhattan: return "building.2"
        case .brooklyn: return "tram.fill"
        case .queens: return "airplane"
        case .bronx: return "leaf"
        case .statenIsland: return "ferry"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(borough.rawValue)
                        .font(.headline)
                    Spacer()
                    Text("\(visitedCount)/\(boroughItems.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))

                        Capsule()
                            .fill(Color.blue)
                            .frame(width: max(1, geometry.size.width * progress))
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Station.self, inMemory: true)
}
