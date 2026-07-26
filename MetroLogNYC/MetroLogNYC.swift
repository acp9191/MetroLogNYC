import SwiftUI
import SwiftData

/// MetroLog NYC - Track your subway journey
@main
struct MetroLogNYCApp: App {
    let modelContainer: ModelContainer
    @State private var locationService = LocationService.shared

    init() {
        do {
            let schema = Schema([Station.self, StationComplex.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        // Preload subway shapes and seed station data in background at startup
        let context = modelContainer.mainContext
        Task { @MainActor in
            StationData.seedIfNeeded(modelContext: context)
            SubwayShapeService.shared.preload()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    locationService.setModelContext(modelContainer.mainContext)
                }
                .environment(locationService)
        }
        .modelContainer(modelContainer)
    }
}
