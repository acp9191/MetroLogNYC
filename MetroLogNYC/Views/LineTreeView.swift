import SwiftUI

/// Position of a station in the route tree
enum StationPosition {
    case first          // First station of a segment
    case middle         // Middle station
    case last           // Last station of a segment
    case branchPoint    // Station where a branch connects
    case single         // Only station in segment
}

/// A row in the tree view showing a station with connecting lines
struct TreeStationRow: View {
    @Bindable var station: Station
    let currentLine: String
    let position: StationPosition
    let isBranch: Bool
    let lineColor: Color
    var showMainLineContinuation: Bool = false  // Shows main line on left while branch is on right
    var onTap: () -> Void

    private let lineWidth: CGFloat = 4
    private let nodeSize: CGFloat = 12
    private let treeWidth: CGFloat = 40

    var body: some View {
        HStack(spacing: 0) {
            // Tree visualization
            ZStack {
                // Main line continuation (when branch shows parallel main line)
                if showMainLineContinuation {
                    mainLineContinuation
                }

                // Vertical line
                verticalLine

                // Branch connector (for branch stations)
                if isBranch && position == .first {
                    branchConnector
                }

                // Station node
                stationNode
            }
            .frame(width: treeWidth)

            // Station content
            stationContent
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    // MARK: - Tree Components

    /// Main line continuation - shows the main line running down the left while branch is on right
    @ViewBuilder
    private var mainLineContinuation: some View {
        GeometryReader { geometry in
            Path { path in
                let mainX = treeWidth * 0.5
                // Draw a continuous line from top to bottom
                path.move(to: CGPoint(x: mainX, y: 0))
                path.addLine(to: CGPoint(x: mainX, y: geometry.size.height))
            }
            .stroke(lineColor, lineWidth: lineWidth)
        }
    }

    @ViewBuilder
    private var verticalLine: some View {
        GeometryReader { geometry in
            Path { path in
                let x = isBranch ? treeWidth * 0.85 : treeWidth * 0.5
                let midY = geometry.size.height / 2

                switch position {
                case .first:
                    // Line from middle to bottom
                    path.move(to: CGPoint(x: x, y: midY))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                case .middle, .branchPoint:
                    // Line from top to bottom
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                case .last:
                    // Line from top to middle
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: midY))
                case .single:
                    // No line
                    break
                }
            }
            .stroke(lineColor, lineWidth: lineWidth)
        }
    }

    @ViewBuilder
    private var branchConnector: some View {
        GeometryReader { geometry in
            Path { path in
                let mainX = treeWidth * 0.5
                let branchX = treeWidth * 0.85
                let midY = geometry.size.height / 2

                // Curved connector from main line to branch
                path.move(to: CGPoint(x: mainX, y: 0))
                path.addQuadCurve(
                    to: CGPoint(x: branchX, y: midY),
                    control: CGPoint(x: mainX, y: midY)
                )
            }
            .stroke(lineColor, lineWidth: lineWidth)
        }
    }

    @ViewBuilder
    private var stationNode: some View {
        let xOffset = isBranch ? treeWidth * 0.35 : 0

        Circle()
            .fill(station.isVisited ? lineColor : Color(.systemBackground))
            .frame(width: nodeSize, height: nodeSize)
            .overlay(
                Circle()
                    .stroke(lineColor, lineWidth: 3)
            )
            .offset(x: xOffset)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    station.toggleVisited()
                }
            }
    }

    // MARK: - Station Content

    private var stationContent: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.body)
                    .foregroundStyle(.primary)

                // Show other lines at this station
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

            if station.isVisited, let date = station.visitedDate {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.leading, isBranch ? 12 : 0)
        .padding(.vertical, 8)
        .padding(.trailing)
    }
}

/// Header for a branch section in the tree
struct BranchHeader: View {
    let branchName: String
    let branchPoint: String
    let lineColor: Color
    let isTopBranch: Bool

    private let treeWidth: CGFloat = 40
    private let lineWidth: CGFloat = 4

    var body: some View {
        HStack(spacing: 0) {
            // Tree connector showing branch split
            ZStack {
                GeometryReader { geometry in
                    Path { path in
                        let mainX = treeWidth * 0.5
                        let branchX = treeWidth * 0.85
                        let height = geometry.size.height

                        // Main line continues
                        path.move(to: CGPoint(x: mainX, y: 0))
                        path.addLine(to: CGPoint(x: mainX, y: height))

                        // Branch splits off
                        if isTopBranch {
                            path.move(to: CGPoint(x: branchX, y: height))
                            path.addQuadCurve(
                                to: CGPoint(x: mainX, y: height * 0.3),
                                control: CGPoint(x: branchX, y: height * 0.3)
                            )
                        } else {
                            path.move(to: CGPoint(x: mainX, y: height * 0.7))
                            path.addQuadCurve(
                                to: CGPoint(x: branchX, y: height),
                                control: CGPoint(x: branchX, y: height * 0.7)
                            )
                        }
                    }
                    .stroke(lineColor, lineWidth: lineWidth)
                }
            }
            .frame(width: treeWidth, height: 50)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(branchName) Branch")
                    .font(.subheadline.bold())
                    .foregroundStyle(lineColor)
                Text("Branches at \(branchPoint)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let station = Station(
        name: "East 180 St",
        lines: [SubwayLine.two, SubwayLine.five],
        latitude: 40.841680,
        longitude: -73.873490,
        borough: Borough.bronx,
        isVisited: true
    )

    List {
        TreeStationRow(
            station: station,
            currentLine: "5",
            position: .middle,
            isBranch: false,
            lineColor: .green,
            onTap: {}
        )
    }
}
