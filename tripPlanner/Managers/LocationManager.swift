//
//  LocationManager.swift
//  tripPlanner
//
//  Created by GitHub Copilot on 16/10/2025.
//

import Foundation
import CoreLocation
import Observation

// MARK: - Location Manager
@MainActor
@Observable
class LocationManager: NSObject {
    // MARK: - Properties
    var location: CLLocation?
    var authorizationStatus: CLAuthorizationStatus
    var isAuthorized: Bool = false
    var locationError: LocationError?
    
    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private var stops: [TransportStop] = []
    
    // MARK: - Computed Properties
    var nearestStop: TransportStop? {
        guard let currentLocation = location, !stops.isEmpty else {
            return nil
        }
        
        return stops.min { stop1, stop2 in
            stop1.distance(from: currentLocation) < stop2.distance(from: currentLocation)
        }
    }
    
    // MARK: - Initialization
    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        self.isAuthorized = locationManager.authorizationStatus == .authorizedWhenInUse ||
                           locationManager.authorizationStatus == .authorizedAlways
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50 // Update every 50 meters
    }
    
    // MARK: - Public Methods
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        guard isAuthorized else {
            locationError = .notAuthorized
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func updateStops(_ newStops: [TransportStop]) {
        self.stops = newStops
    }
    
    func getNearestStop(of type: StopType? = nil) -> TransportStop? {
        guard let currentLocation = location else {
            return nil
        }
        
        let filteredStops = type != nil ? stops.filter { $0.stopType == type } : stops
        
        guard !filteredStops.isEmpty else {
            return nil
        }
        
        return filteredStops.min { stop1, stop2 in
            stop1.distance(from: currentLocation) < stop2.distance(from: currentLocation)
        }
    }
    
    func getStopsSortedByDistance(of type: StopType? = nil) -> [TransportStop] {
        guard let currentLocation = location else {
            return stops
        }
        
        let filteredStops = type != nil ? stops.filter { $0.stopType == type } : stops
        
        return filteredStops.sorted { stop1, stop2 in
            stop1.distance(from: currentLocation) < stop2.distance(from: currentLocation)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            self.isAuthorized = manager.authorizationStatus == .authorizedWhenInUse ||
                               manager.authorizationStatus == .authorizedAlways
            
            if self.isAuthorized {
                self.locationError = nil
                self.startUpdatingLocation()
            } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
                self.locationError = .notAuthorized
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let newLocation = locations.last else { return }
            self.location = newLocation
            self.locationError = nil
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.locationError = .notAuthorized
                case .network:
                    self.locationError = .networkError
                default:
                    self.locationError = .unknown
                }
            } else {
                self.locationError = .unknown
            }
        }
    }
}

// MARK: - Location Error
enum LocationError: Error, LocalizedError {
    case notAuthorized
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Location access not authorized. Please enable location services in Settings."
        case .networkError:
            return "Unable to retrieve location due to network issues."
        case .unknown:
            return "An unknown error occurred while accessing location."
        }
    }
}
