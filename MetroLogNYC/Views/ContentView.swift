import SwiftUI
import SwiftData

/// Main content view with tab navigation
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var stations: [Station]
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            StationListView()
                .tabItem {
                    Label("Stations", systemImage: "list.bullet")
                }
                .tag(1)

            StationMapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(2)
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Station.self, inMemory: true)
}
