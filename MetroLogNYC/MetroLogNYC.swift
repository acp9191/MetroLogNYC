import SwiftUI
import SwiftData

/// MetroLog NYC - Track your subway journey
@main
struct MetroLogNYCApp: App {
    let modelContainer: ModelContainer
    @StateObject private var locationService = LocationService.shared

    init() {
        do {
            let schema = Schema([Station.self, StationComplex.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        // Preload subway shapes in background for faster map loading
        Task { @MainActor in
            SubwayShapeService.shared.preload()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    seedDataIfNeeded()
                    locationService.setModelContext(modelContainer.mainContext)
                }
                .environmentObject(locationService)
        }
        .modelContainer(modelContainer)
    }

    @MainActor
    private func seedDataIfNeeded() {
        StationData.seedIfNeeded(modelContext: modelContainer.mainContext)
    }
}
