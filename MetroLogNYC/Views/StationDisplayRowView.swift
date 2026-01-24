import SwiftUI

/// A row view that displays a subway stop
struct StationDisplayRowView: View {
    let item: StationDisplayItem
    var onToggleVisited: (() -> Void)?

    // Lines ordered by trunk line (MTA standard grouping)
    private static let lineOrder = [
        "1", "2", "3", "4", "5", "6", "7",
        "A", "C", "E", "B", "D", "F", "M",
        "G", "J", "Z", "L",
        "N", "Q", "R", "W",
        "GS", "FS", "RS", "SIR"
    ]

    private var sortedLines: [String] {
        item.lines.sorted { line1, line2 in
            let index1 = Self.lineOrder.firstIndex(of: line1) ?? Int.max
            let index2 = Self.lineOrder.firstIndex(of: line2) ?? Int.max
            return index1 < index2
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Visited indicator with partial state
            visitedIndicator
                .onTapGesture {
                    onToggleVisited?()
                }

            VStack(alignment: .leading, spacing: 4) {
                // Stop name
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                // Subway lines
                HStack(spacing: 4) {
                    ForEach(sortedLines.prefix(10), id: \.self) { line in
                        LineBadge(line: line, size: 20)
                    }
                    if sortedLines.count > 10 {
                        Text("+\(sortedLines.count - 10)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // Borough
                Text(item.borough.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Chevron for detail view
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var visitedIndicator: some View {
        if item.isVisited {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
        } else {
            Image(systemName: "circle")
                .font(.title2)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    let station1 = Station(
        name: "Bedford Av",
        lines: [SubwayLine.l],
        latitude: 40.717304,
        longitude: -73.956872,
        borough: Borough.brooklyn,
        isVisited: true,
        visitedDate: Date()
    )
    let station2 = Station(
        name: "Astor Pl",
        lines: [SubwayLine.six],
        latitude: 40.730054,
        longitude: -73.991070,
        borough: Borough.manhattan,
        isVisited: false
    )
    return List {
        StationDisplayRowView(item: StationDisplayItem(station: station1))
        StationDisplayRowView(item: StationDisplayItem(station: station2))
    }
}
