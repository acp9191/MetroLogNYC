import SwiftUI
import MapKit

/// Detail view for a station complex or standalone station
struct ComplexDetailView: View {
    let item: StationDisplayItem
    @Environment(\.dismiss) private var dismiss
    @State private var cameraPosition: MapCameraPosition = .automatic

    private var centerCoordinate: CLLocationCoordinate2D {
        guard let first = item.stations.first else {
            return CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        }
        return first.coordinate
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    mapSection
                    contentSection
                }
                .padding(.vertical)
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Map Section

    private var mapSection: some View {
        Map(position: $cameraPosition) {
            ForEach(item.stations) { station in
                Annotation(station.name, coordinate: station.coordinate) {
                    stationMarker(for: station)
                }
            }
        }
        .onAppear {
            cameraPosition = .region(MKCoordinateRegion(
                center: centerCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func stationMarker(for station: Station) -> some View {
        Circle()
            .fill(station.isVisited ? Color.blue : Color.red)
            .frame(width: 12, height: 12)
            .overlay {
                Circle().stroke(Color.white, lineWidth: 2)
            }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(spacing: 16) {
            linesSection
            boroughSection
            visitStatusSection
            if item.isComplex {
                stationsInComplexSection
            }
            directionsButton
        }
        .padding(.horizontal)
    }

    // MARK: - Lines Section

    private var linesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subway Lines")
                .font(.headline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 8) {
                ForEach(item.lines.sorted(), id: \.self) { line in
                    LineBadge(line: line, size: 36)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Borough Section

    private var boroughSection: some View {
        HStack {
            Label {
                Text(item.borough.rawValue)
                    .font(.body)
            } icon: {
                Image(systemName: "building.2")
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Visit Status Section

    private var visitStatusSection: some View {
        VStack(spacing: 12) {
            HStack {
                visitStatusLabel
                Spacer()
                visitButton
            }

            if item.isComplex {
                Text("\(item.visitedCount) of \(item.stationCount) stations visited")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if item.isVisited, let date = item.lastVisitedDate {
                HStack {
                    Text("Last visited on")
                    Text(date, style: .date)
                    Spacer()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var visitStatusLabel: some View {
        Label {
            Text(item.isComplex ? "Mark Complex as Visited" : "Visited")
                .font(.headline)
        } icon: {
            visitStatusIcon
        }
    }

    @ViewBuilder
    private var visitStatusIcon: some View {
        if item.isVisited {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.blue)
        } else if item.isPartiallyVisited {
            Image(systemName: "circle.lefthalf.filled")
                .foregroundStyle(.orange)
        } else {
            Image(systemName: "circle")
                .foregroundStyle(.gray)
        }
    }

    private var visitButton: some View {
        Button {
            item.toggleVisited()
        } label: {
            Text(item.isVisited ? "Unvisit" : "Visit")
                .font(.subheadline.bold())
        }
        .buttonStyle(.borderedProminent)
        .tint(item.isVisited ? .orange : .blue)
    }

    // MARK: - Stations in Complex Section

    private var stationsInComplexSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stations in Complex")
                .font(.headline)
                .foregroundStyle(.secondary)

            ForEach(item.stations) { station in
                StationInComplexRow(station: station)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Directions Button

    private var directionsButton: some View {
        Button {
            openInMaps()
        } label: {
            Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond")
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
    }

    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: centerCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = item.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit
        ])
    }
}

// MARK: - Station In Complex Row

struct StationInComplexRow: View {
    @Bindable var station: Station

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: station.isVisited ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(station.isVisited ? .blue : .gray)
                .onTapGesture {
                    station.toggleVisited()
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.subheadline)

                stationLines
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var stationLines: some View {
        HStack(spacing: 4) {
            ForEach(station.lines.prefix(6), id: \.self) { line in
                LineBadge(line: line, size: 16)
            }
        }
    }
}

#Preview {
    let lines: [SubwayLine] = [.one, .two, .three, .seven, .n, .q, .r, .w, .gs]
    let station = Station(
        name: "Times Sq-42 St",
        lines: lines,
        latitude: 40.754672,
        longitude: -73.986754,
        borough: Borough.manhattan,
        isVisited: true,
        visitedDate: Date()
    )
    return ComplexDetailView(item: StationDisplayItem(station: station))
}
