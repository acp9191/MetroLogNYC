import SwiftUI

/// A row view that displays either a station complex or standalone station
struct StationDisplayRowView: View {
    let item: StationDisplayItem
    var onToggleVisited: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            // Visited indicator with partial state for complexes
            visitedIndicator
                .onTapGesture {
                    onToggleVisited?()
                }

            VStack(alignment: .leading, spacing: 4) {
                // Station/Complex name
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                // Subway lines
                HStack(spacing: 4) {
                    ForEach(item.lines.sorted().prefix(10), id: \.self) { line in
                        LineBadge(line: line, size: 20)
                    }
                    if item.lines.count > 10 {
                        Text("+\(item.lines.count - 10)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // Borough and visit info
                HStack {
                    Text(item.borough.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if item.isComplex && item.isPartiallyVisited {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text("\(item.visitedCount)/\(item.stationCount) visited")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    } else if item.isVisited, let date = item.lastVisitedDate {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
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
        } else if item.isPartiallyVisited {
            // Partial visit indicator for complexes
            ZStack {
                Circle()
                    .stroke(Color.orange, lineWidth: 2)
                    .frame(width: 24, height: 24)
                Circle()
                    .fill(Color.orange)
                    .frame(width: 12, height: 12)
            }
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
