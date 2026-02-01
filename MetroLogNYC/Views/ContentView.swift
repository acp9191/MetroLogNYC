import SwiftUI
import SwiftData

/// Main content view with tab navigation
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var locationService: LocationService
    @Query private var stations: [Station]
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                StationListView()
                    .tabItem {
                        Label("Stops", systemImage: "list.bullet")
                    }
                    .tag(1)

                StationMapView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                    .tag(2)
            }
            .tint(.blue)

            // Nearby station suggestion banner
            if let suggestion = locationService.nearbyStationSuggestion {
                NearbySuggestionBannerView(
                    item: suggestion,
                    onMarkVisited: {
                        locationService.markSuggestionAsVisited()
                    },
                    onDismiss: {
                        locationService.dismissCurrentSuggestion()
                    }
                )
                .padding(.bottom, 90) // Above tab bar
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Station.self, inMemory: true)
        .environmentObject(LocationService.shared)
}
