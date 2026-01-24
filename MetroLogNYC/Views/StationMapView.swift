import SwiftUI
import SwiftData
import MapKit

/// Map view showing all subway stations with line colors
struct StationMapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var stations: [Station]

    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    ))
    @State private var selectedStation: Station?
    @State private var showingDetail = false
    @State private var visitedFilter: StationFilter = .all
    @State private var lineFilter: String? = nil
    @State private var showUserLocation = false
    @State private var showRouteLines = true
    @State private var shapesLoaded = false

    private var filteredStations: [Station] {
        var result = stations

        // Line filter
        if let line = lineFilter {
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

        return result
    }

    // All lines for the filter
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

    /// Shapes to display based on current filter
    private var filteredShapes: [SubwayLineShape] {
        let allShapes = SubwayShapeService.shared.allShapes()
        if let line = lineFilter {
            return allShapes.filter { $0.lineId == line }
        }
        return allShapes
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition) {
                    // Route lines (rendered first, underneath stations)
                    if showRouteLines && shapesLoaded {
                        ForEach(filteredShapes, id: \.lineId) { lineShape in
                            ForEach(Array(lineShape.shapes.enumerated()), id: \.offset) { index, coordinates in
                                MapPolyline(coordinates: coordinates)
                                    .stroke(
                                        SubwayLine.from(lineShape.lineId)?.color ?? .gray,
                                        lineWidth: lineFilter == nil ? 2 : 4
                                    )
                            }
                        }
                    }

                    // Station markers
                    ForEach(filteredStations) { station in
                        Annotation(
                            station.name,
                            coordinate: station.coordinate,
                            anchor: .center
                        ) {
                            StationMarker(
                                station: station,
                                isSelected: selectedStation?.id == station.id,
                                highlightLine: lineFilter
                            )
                            .onTapGesture {
                                selectedStation = station
                            }
                        }
                    }

                    if showUserLocation {
                        UserAnnotation()
                    }
                }
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }

                // Floating controls
                VStack(spacing: 0) {
                    // Top bar with line filter
                    VStack(spacing: 8) {
                        // Line filter scroll
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                // All lines button
                                Button {
                                    lineFilter = nil
                                } label: {
                                    Text("All")
                                        .font(.caption.bold())
                                        .foregroundStyle(lineFilter == nil ? .white : .primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(lineFilter == nil ? Color.blue : Color(.secondarySystemBackground))
                                        .clipShape(Capsule())
                                }

                                ForEach(allLines, id: \.self) { line in
                                    Button {
                                        lineFilter = lineFilter == line ? nil : line
                                    } label: {
                                        LineBadge(line: line, size: 28)
                                            .opacity(lineFilter == nil || lineFilter == line ? 1.0 : 0.4)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)

                    Spacer()

                    // Bottom controls
                    HStack {
                        // Filter button (visited status)
                        Menu {
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
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.title2)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        // Route lines toggle
                        Button {
                            showRouteLines.toggle()
                        } label: {
                            Image(systemName: showRouteLines ? "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath.fill" : "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath")
                                .font(.title2)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        Spacer()

                        // Location button
                        Button {
                            showUserLocation.toggle()
                        } label: {
                            Image(systemName: showUserLocation ? "location.fill" : "location")
                                .font(.title2)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        // Reset view button
                        Button {
                            withAnimation {
                                cameraPosition = .region(MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
                                    span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                                ))
                            }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title2)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedStation) { oldValue, newValue in
                if newValue != nil {
                    showingDetail = true
                }
            }
            .sheet(isPresented: $showingDetail) {
                selectedStation = nil
            } content: {
                if let station = selectedStation {
                    // Show complex if station is part of one, otherwise show as standalone
                    let item = if let complex = station.complex {
                        StationDisplayItem(complex: complex)
                    } else {
                        StationDisplayItem(station: station)
                    }
                    ComplexDetailView(item: item)
                        .presentationDetents([.medium, .large])
                }
            }
            .task {
                if !shapesLoaded {
                    await SubwayShapeService.shared.waitForLoad()
                    shapesLoaded = true
                }
            }
        }
    }
}

// MARK: - Station Marker
struct StationMarker: View {
    let station: Station
    var isSelected: Bool = false
    var highlightLine: String? = nil

    private var lineColor: Color {
        if let line = highlightLine, station.lines.contains(line) {
            return SubwayLine.from(line)?.color ?? .gray
        }
        guard let firstLine = station.lines.first,
              let subwayLine = SubwayLine.from(firstLine) else {
            return .gray
        }
        return subwayLine.color
    }

    private var size: CGFloat { isSelected ? 24 : 14 }

    var body: some View {
        Circle()
            .fill(lineColor)
            .frame(width: size, height: size)
            .overlay {
                if station.isVisited {
                    Circle().stroke(Color.white, lineWidth: 2)
                } else {
                    Circle().fill(Color.white).frame(width: size * 0.4, height: size * 0.4)
                }
            }
    }
}

#Preview {
    StationMapView()
        .modelContainer(for: Station.self, inMemory: true)
}
