//
//  TransportStop.swift
//  tripPlanner
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

// MARK: - Sample Data
extension TransportStop {
    static let sampleBusStop = TransportStop(
        name: "Town Hall Station, George St",
        stopId: "G203519",
        stopType: .bus,
        latitude: -33.8735,
        longitude: 151.2066
    )
    
    static let sampleLightRailStop = TransportStop(
        name: "Central Station, Eddy Ave",
        stopId: "203294",
        stopType: .lightRail,
        latitude: -33.8830,
        longitude: 151.2065
    )
    
    static let sampleStops: [TransportStop] = [
        sampleBusStop,
        sampleLightRailStop,
        TransportStop(
            name: "Circular Quay",
            stopId: "G200066",
            stopType: .bus,
            latitude: -33.8615,
            longitude: 151.2111
        )
    ]
}
