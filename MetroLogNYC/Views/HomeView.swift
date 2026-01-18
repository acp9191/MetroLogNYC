import SwiftUI
import SwiftData

/// Home view displaying overall progress and line cards
struct HomeView: View {
    @Query private var stations: [Station]
    @State private var selectedLine: String?

    private var visitedCount: Int {
        stations.filter { $0.isVisited }.count
    }

    private var progress: Double {
        guard !stations.isEmpty else { return 0 }
        return Double(visitedCount) / Double(stations.count)
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

    // Flat list of all lines for the grid
    private let allLines = ["1", "2", "3", "4", "5", "6", "7", "A", "B", "C", "D", "E", "F", "G", "J", "L", "M", "N", "Q", "R", "W", "Z", "GS", "FS", "RS", "SIR"]

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
                        totalCount: stations.count,
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
                                    LineCard(line: line, stations: stations)
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
                            ForEach(["Manhattan", "Brooklyn", "Queens", "Bronx", "Staten Island"], id: \.self) { borough in
                                BoroughCard(borough: borough, stations: stations)
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
                    Text("of \(totalCount) stations")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 180, height: 180)

            // Percentage badge
            Text("\(Int(progress * 100))% Complete")
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
    let stations: [Station]

    private var lineStations: [Station] {
        stations.filter { $0.lines.contains(line) }
    }

    private var visitedCount: Int {
        lineStations.filter { $0.isVisited }.count
    }

    private var progress: Double {
        guard !lineStations.isEmpty else { return 0 }
        return Double(visitedCount) / Double(lineStations.count)
    }

    var body: some View {
        VStack(spacing: 8) {
            LineBadge(line: line, size: 44)

            Text("\(visitedCount)/\(lineStations.count)")
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
    let borough: String
    let stations: [Station]

    private var boroughStations: [Station] {
        stations.filter { $0.borough == borough }
    }

    private var visitedCount: Int {
        boroughStations.filter { $0.isVisited }.count
    }

    private var progress: Double {
        guard !boroughStations.isEmpty else { return 0 }
        return Double(visitedCount) / Double(boroughStations.count)
    }

    private var icon: String {
        switch borough {
        case "Manhattan": return "building.2"
        case "Brooklyn": return "tram.fill"
        case "Queens": return "airplane"
        case "Bronx": return "leaf"
        case "Staten Island": return "ferry"
        default: return "mappin"
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
                    Text(borough)
                        .font(.headline)
                    Spacer()
                    Text("\(visitedCount)/\(boroughStations.count)")
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
