import SwiftUI

/// A row view displaying station information in the list
struct StationRowView: View {
    let station: Station
    var onToggleVisited: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            // Visited indicator
            Image(systemName: station.isVisited ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(station.isVisited ? .blue : .gray)
                .onTapGesture {
                    onToggleVisited?()
                }

            VStack(alignment: .leading, spacing: 4) {
                // Station name
                Text(station.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                // Subway lines
                HStack(spacing: 4) {
                    ForEach(station.lines.prefix(8), id: \.self) { line in
                        LineBadge(line: line, size: 20)
                    }
                    if station.lines.count > 8 {
                        Text("+\(station.lines.count - 8)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // Borough and visited date
                HStack {
                    Text(station.borough.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if station.isVisited, let date = station.visitedDate {
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
}

#Preview {
    List {
        StationRowView(
            station: Station(
                name: "Times Sq-42 St",
                lines: [.one, .two, .three, .seven, .n, .q, .r, .w, .gs],
                latitude: 40.754672,
                longitude: -73.986754,
                borough: .manhattan,
                isVisited: true,
                visitedDate: Date()
            )
        )

        StationRowView(
            station: Station(
                name: "14 St-Union Sq",
                lines: [.four, .five, .six, .l, .n, .q, .r, .w],
                latitude: 40.735736,
                longitude: -73.990568,
                borough: .manhattan,
                isVisited: false
            )
        )
    }
}
