import SwiftUI
import SwiftData
import MapKit

/// Map view showing all subway stations with line colors
struct StationMapView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocationService.self) private var locationService
    @Query private var stations: [Station]

    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    ))
    @State private var selectedStation: Station?
    @State private var showingDetail = false
    @State private var visitedFilter: StationFilter = .all
    @State private var lineFilter: String? = nil
    @State private var showRouteLines = true
    @State private var shapesLoaded = false
    @State private var visibleRegion: MKCoordinateRegion?

    private var filteredStations: [Station] {
        stations.filter { station in
            (lineFilter == nil || station.lines.contains(lineFilter!))
            && (visitedFilter == .all || (visitedFilter == .visited) == station.isVisited)
        }
    }

    /// Stations to actually render as annotations.
    /// A single-line filter already yields a small set, so render all of it. Otherwise cull
    /// to the visible region (plus a margin) so we don't diff ~500 annotation views at once.
    private var renderedStations: [Station] {
        let result = filteredStations
        guard lineFilter == nil, let region = visibleRegion else {
            return result
        }
        // Half-span expanded by 1.5x so annotations exist just outside the viewport while panning.
        let latMargin = region.span.latitudeDelta * 0.75
        let lonMargin = region.span.longitudeDelta * 0.75
        return result.filter { station in
            abs(station.latitude - region.center.latitude) <= latMargin &&
            abs(station.longitude - region.center.longitude) <= lonMargin
        }
    }

    // All lines for the filter, ordered by trunk line (MTA standard grouping)
    private let allLines = SubwayLine.displayOrder

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
                    ForEach(renderedStations) { station in
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

                    if locationService.isLocationEnabled {
                        UserAnnotation()
                    }
                }
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    visibleRegion = context.region
                }

                // Floating controls
                VStack(spacing: 0) {
                    LineFilterBar(selectedLine: $lineFilter, allLines: allLines)
                        .background(.ultraThinMaterial)
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
                            if locationService.authorizationStatus == .notDetermined {
                                locationService.requestAuthorization()
                            }
                            locationService.isLocationEnabled.toggle()
                        } label: {
                            Image(systemName: locationService.isLocationEnabled ? "location.fill" : "location")
                                .font(.title2)
                                .foregroundStyle(locationService.authorizationStatus == .denied ? .red : .primary)
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
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
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
        .environment(LocationService.shared)
}
