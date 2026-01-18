import SwiftUI
import SwiftData

/// MetroLog NYC - Track your subway journey
@main
struct MetroLogNYCApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([Station.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    seedDataIfNeeded()
                }
        }
        .modelContainer(modelContainer)
    }

    @MainActor
    private func seedDataIfNeeded() {
        StationData.seedIfNeeded(modelContext: modelContainer.mainContext)
    }
}
