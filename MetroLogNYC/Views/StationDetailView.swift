import SwiftUI
import MapKit

/// Detail view for a single station
struct StationDetailView: View {
    @Bindable var station: Station
    @Environment(\.dismiss) private var dismiss
    @State private var showingComplexDetail = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Map Preview
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: station.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    ))) {
                        Marker(station.name, coordinate: station.coordinate)
                            .tint(station.isVisited ? .blue : .red)
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // Station Info
                    VStack(spacing: 16) {
                        // Lines Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Subway Lines")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 40))
                            ], spacing: 8) {
                                ForEach(station.lines, id: \.self) { line in
                                    LineBadge(line: line, size: 36)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Borough Section
                        HStack {
                            Label {
                                Text(station.borough.rawValue)
                                    .font(.body)
                            } icon: {
                                Image(systemName: "building.2")
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Complex Section (if part of a complex)
                        if let complex = station.complex {
                            Button {
                                showingComplexDetail = true
                            } label: {
                                HStack {
                                    Label {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Part of Complex")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text(complex.name)
                                                .font(.body)
                                                .foregroundStyle(.primary)
                                        }
                                    } icon: {
                                        Image(systemName: "arrow.triangle.branch")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Visited Toggle
                        VStack(spacing: 12) {
                            Toggle(isOn: Binding(
                                get: { station.isVisited },
                                set: { _ in station.toggleVisited() }
                            )) {
                                Label {
                                    Text("Visited")
                                        .font(.headline)
                                } icon: {
                                    Image(systemName: station.isVisited ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(station.isVisited ? .blue : .gray)
                                }
                            }
                            .tint(.blue)

                            if station.isVisited, let date = station.visitedDate {
                                HStack {
                                    Text("Visited on")
                                        .foregroundStyle(.secondary)
                                    Text(date, style: .date)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                .font(.caption)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Directions Button
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
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(station.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingComplexDetail) {
                if let complex = station.complex {
                    ComplexDetailView(item: StationDisplayItem(complex: complex))
                }
            }
        }
    }

    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: station.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = station.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit
        ])
    }
}

#Preview {
    StationDetailView(
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
}
