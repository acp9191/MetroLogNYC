import Foundation
import CoreLocation
import SwiftUI
import SwiftData

/// Service that manages location updates and detects nearby unvisited subway stations
@MainActor
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()

    // MARK: - Published Properties

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var nearbyStationSuggestion: StationDisplayItem?
    @Published var isLocationEnabled: Bool = false {
        didSet {
            if isLocationEnabled {
                startLocationUpdates()
            } else {
                stopLocationUpdates()
            }
        }
    }

    // MARK: - Private Properties

    private let locationManager = CLLocationManager()
    private var modelContext: ModelContext?

    /// Radius in meters to detect nearby stations
    private let proximityRadius: CLLocationDistance = 75

    /// Cooldown between suggestions for a specific station in seconds (5 minutes)
    private let suggestionCooldown: TimeInterval = 300

    /// Tracks when each station was dismissed (for per-station cooldown)
    private var dismissedStationTimes: [UUID: Date] = [:]

    /// Currently suggested station ID (for hysteresis - don't re-suggest while still in radius)
    private var currentSuggestionId: UUID?

    // MARK: - Initialization

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public Methods

    /// Set the model context for querying stations and start location tracking
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context

        // Automatically start location tracking
        if authorizationStatus == .notDetermined {
            requestAuthorization()
        } else if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            isLocationEnabled = true
        }
    }

    /// Request location authorization
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Mark the current suggestion as visited
    func markSuggestionAsVisited() {
        guard let suggestion = nearbyStationSuggestion else { return }
        suggestion.markVisited()
        try? modelContext?.save()
        currentSuggestionId = nil
        nearbyStationSuggestion = nil

        // Re-check for other nearby stations after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self, let location = self.currentLocation else { return }
            self.checkForNearbyStations(at: location)
        }
    }

    /// Dismiss the current suggestion without marking as visited
    func dismissCurrentSuggestion() {
        guard let suggestion = nearbyStationSuggestion else { return }
        dismissedStationTimes[suggestion.id] = Date()
        currentSuggestionId = nil
        nearbyStationSuggestion = nil

        // Re-check for other nearby stations after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self, let location = self.currentLocation else { return }
            self.checkForNearbyStations(at: location)
        }
    }

    // MARK: - Private Methods

    private func startLocationUpdates() {
        switch authorizationStatus {
        case .notDetermined:
            requestAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            isLocationEnabled = false
        @unknown default:
            break
        }
    }

    private func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        withAnimation {
            nearbyStationSuggestion = nil
        }
        currentSuggestionId = nil
    }

    private func checkForNearbyStations(at location: CLLocation) {
        guard let modelContext = modelContext else { return }

        // Fetch all stations and complexes
        let stationDescriptor = FetchDescriptor<Station>()
        let complexDescriptor = FetchDescriptor<StationComplex>()

        guard let stations = try? modelContext.fetch(stationDescriptor),
              let complexes = try? modelContext.fetch(complexDescriptor) else {
            return
        }

        // Create display items
        let displayItems = StationDisplayItem.createDisplayItems(stations: stations, complexes: complexes)

        // Filter to unvisited items only
        let unvisitedItems = displayItems.filter { !$0.isVisited }

        // Find the nearest unvisited station within radius
        var nearestItem: StationDisplayItem?
        var nearestDistance: CLLocationDistance = .infinity

        let now = Date()
        for item in unvisitedItems {
            // Skip if dismissed within cooldown period
            if let dismissedTime = dismissedStationTimes[item.id],
               now.timeIntervalSince(dismissedTime) < suggestionCooldown {
                continue
            }

            let itemLocation = CLLocation(
                latitude: item.centerCoordinate.latitude,
                longitude: item.centerCoordinate.longitude
            )
            let distance = location.distance(from: itemLocation)

            if distance <= proximityRadius && distance < nearestDistance {
                nearestDistance = distance
                nearestItem = item
            }
        }

        // Hysteresis: if we already suggested this station and user is still in range, don't re-suggest
        if let nearest = nearestItem {
            if nearest.id == currentSuggestionId {
                return
            }
            currentSuggestionId = nearest.id
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                nearbyStationSuggestion = nearest
            }
        } else {
            // User left the radius of the current suggestion
            if nearbyStationSuggestion == nil {
                currentSuggestionId = nil
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            currentLocation = location
            checkForNearbyStations(at: location)
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorizationStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                // Automatically enable location when authorized
                if !isLocationEnabled {
                    isLocationEnabled = true
                } else {
                    locationManager.startUpdatingLocation()
                }
            case .denied, .restricted:
                isLocationEnabled = false
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location errors are expected in some cases (e.g., no GPS signal)
        // We silently handle them here
    }
}
