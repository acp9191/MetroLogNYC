import SwiftUI
import SwiftData

/// Home view displaying overall progress and line cards
struct HomeView: View {
    @Query private var stations: [Station]
    @Query private var complexes: [StationComplex]
    @State private var selectedLine: String?

    /// Visited/total tallies computed in a single pass over the display items.
    /// Avoids rebuilding the display-item list (and re-scanning it) once per card.
    private var metrics: HomeMetrics {
        let items = StationDisplayItem.createDisplayItems(stations: stations, complexes: complexes)
        var result = HomeMetrics()
        for item in items {
            let visited = item.isVisited
            result.overall.add(visited: visited)
            result.byBorough[item.borough, default: ProgressStats()].add(visited: visited)
            // De-duplicate lines so a stop counts once per line (matches `.contains` semantics)
            for line in Set(item.lines) {
                result.byLine[line, default: ProgressStats()].add(visited: visited)
            }
        }
        return result
    }

    // Lines ordered by trunk line (MTA standard grouping)
    private let allLines = SubwayLine.displayOrder

    var body: some View {
        let metrics = self.metrics
        return NavigationStack {
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
                        visitedCount: metrics.overall.visited,
                        totalCount: metrics.overall.total,
                        progress: metrics.overall.progress
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
                                let stats = metrics.byLine[line] ?? ProgressStats()
                                NavigationLink(destination: LineDetailView(line: line)) {
                                    LineCard(line: line, visited: stats.visited, total: stats.total)
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
                                let stats = metrics.byBorough[borough] ?? ProgressStats()
                                BoroughCard(borough: borough, visited: stats.visited, total: stats.total)
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
                    AnimatedCounter(value: visitedCount)
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

// MARK: - Progress Tallies
struct ProgressStats {
    var visited = 0
    var total = 0

    var progress: Double {
        total > 0 ? Double(visited) / Double(total) : 0
    }

    mutating func add(visited didVisit: Bool) {
        total += 1
        if didVisit { visited += 1 }
    }
}

/// Aggregated visited/total counts for the Home screen, built in one pass.
struct HomeMetrics {
    var overall = ProgressStats()
    var byLine: [String: ProgressStats] = [:]
    var byBorough: [Borough: ProgressStats] = [:]
}

// MARK: - Line Card
struct LineCard: View {
    let line: String
    let visited: Int
    let total: Int

    private var progress: Double {
        total > 0 ? Double(visited) / Double(total) : 0
    }

    var body: some View {
        VStack(spacing: 8) {
            LineBadge(line: line, size: 44)

            Text("\(visited)/\(total)")
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
    let visited: Int
    let total: Int

    private var progress: Double {
        total > 0 ? Double(visited) / Double(total) : 0
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
                    Text("\(visited)/\(total)")
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

// MARK: - Animated Counter
struct AnimatedCounter: View {
    let value: Int

    @State private var displayedValue: Int = 0

    var body: some View {
        Text("\(displayedValue)")
            .contentTransition(.numericText(value: Double(displayedValue)))
            .animation(.snappy(duration: 0.3), value: displayedValue)
            .onChange(of: value) { oldValue, newValue in
                displayedValue = newValue
            }
            .onAppear {
                displayedValue = value
            }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Station.self, inMemory: true)
}
