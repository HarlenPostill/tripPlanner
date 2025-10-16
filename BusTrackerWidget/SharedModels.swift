//
//  SharedModels.swift
//  BusTrackerWidget
//
//  Created by GitHub Copilot on 16/10/2025.
//

import Foundation
import CoreLocation

// MARK: - Stop Type Enum
enum StopType: String, Codable, CaseIterable, Identifiable {
    case bus = "bus"
    case lightRail = "lightRail"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .bus:
            return "Bus"
        case .lightRail:
            return "Light Rail"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .bus:
            return "bus"
        case .lightRail:
            return "tram"
        }
    }
    
    var urlType: String {
        switch self {
        case .bus:
            return "stop"
        case .lightRail:
            return "platform"
        }
    }
    
    var excludedModes: String {
        switch self {
        case .bus:
            return "2,9,11,1,4,7"
        case .lightRail:
            return "2,9,11,1,5,7"
        }
    }
}

// MARK: - Transport Stop Model
struct TransportStop: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var stopId: String
    var stopType: StopType
    var latitude: Double
    var longitude: Double
    var createdAt: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: UUID = UUID(), name: String, stopId: String, stopType: StopType, latitude: Double, longitude: Double, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.stopId = stopId
        self.stopType = stopType
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
    }
    
    init(id: UUID = UUID(), name: String, stopId: String, stopType: StopType, coordinate: CLLocationCoordinate2D, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.stopId = stopId
        self.stopType = stopType
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.createdAt = createdAt
    }
    
    // Distance from a given location
    func distance(from location: CLLocation) -> CLLocationDistance {
        let stopLocation = CLLocation(latitude: latitude, longitude: longitude)
        return location.distance(from: stopLocation)
    }
    
    // Formatted distance string
    func formattedDistance(from location: CLLocation) -> String {
        let distanceInMeters = distance(from: location)
        
        if distanceInMeters < 1000 {
            return String(format: "%.0f m", distanceInMeters)
        } else {
            return String(format: "%.1f km", distanceInMeters / 1000)
        }
    }
    
    static func == (lhs: TransportStop, rhs: TransportStop) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Shared Stops Manager for Widget
class SharedStopsManager {
    static let shared = SharedStopsManager()
    
    private let appGroupIdentifier = "group.com.hrln.tripPlanner"
    private let stopsKey = "savedTransportStops"
    
    private var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }
    
    private init() {}
    
    func loadStops() -> [TransportStop] {
        guard let data = userDefaults.data(forKey: stopsKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([TransportStop].self, from: data)
        } catch {
            print("Failed to load stops: \(error.localizedDescription)")
            return []
        }
    }
    
    func getNearestStop(to location: CLLocation, ofType type: StopType? = nil) -> TransportStop? {
        let stops = loadStops()
        let filteredStops = type != nil ? stops.filter { $0.stopType == type } : stops
        
        guard !filteredStops.isEmpty else {
            return nil
        }
        
        return filteredStops.min { stop1, stop2 in
            stop1.distance(from: location) < stop2.distance(from: location)
        }
    }
}
