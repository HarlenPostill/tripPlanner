//
//  StopsManager.swift
//  tripPlanner
//
//  Created by GitHub Copilot on 16/10/2025.
//

import Foundation
import Observation

// MARK: - Stops Manager
@Observable
class StopsManager {
    // MARK: - Singleton
    static let shared = StopsManager()
    
    // MARK: - Properties
    var stops: [TransportStop] = []
    
    // MARK: - Constants
    private let appGroupIdentifier = "group.com.hrln.tripPlanner"
    private let stopsKey = "savedTransportStops"
    
    // MARK: - Computed Properties
    private var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }
    
    var busStops: [TransportStop] {
        stops.filter { $0.stopType == .bus }
    }
    
    var lightRailStops: [TransportStop] {
        stops.filter { $0.stopType == .lightRail }
    }
    
    // MARK: - Initialization
    private init() {
        loadStops()
    }
    
    // MARK: - CRUD Operations
    func addStop(_ stop: TransportStop) {
        // Check if stop with same ID already exists
        guard !stops.contains(where: { $0.id == stop.id }) else {
            return
        }
        
        stops.append(stop)
        saveStops()
    }
    
    func updateStop(_ stop: TransportStop) {
        guard let index = stops.firstIndex(where: { $0.id == stop.id }) else {
            return
        }
        
        stops[index] = stop
        saveStops()
    }
    
    func deleteStop(_ stop: TransportStop) {
        stops.removeAll { $0.id == stop.id }
        saveStops()
    }
    
    func deleteStops(at offsets: IndexSet) {
        stops.remove(atOffsets: offsets)
        saveStops()
    }
    
    func deleteStop(by id: UUID) {
        stops.removeAll { $0.id == id }
        saveStops()
    }
    
    func getStop(by id: UUID) -> TransportStop? {
        stops.first { $0.id == id }
    }
    
    func getStops(of type: StopType) -> [TransportStop] {
        stops.filter { $0.stopType == type }
    }
    
    // MARK: - Persistence
    private func saveStops() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(stops)
            userDefaults.set(data, forKey: stopsKey)
            userDefaults.synchronize()
        } catch {
            print("Failed to save stops: \(error.localizedDescription)")
        }
    }
    
    private func loadStops() {
        guard let data = userDefaults.data(forKey: stopsKey) else {
            // Load default sample stops if none exist
            stops = []
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            stops = try decoder.decode([TransportStop].self, from: data)
        } catch {
            print("Failed to load stops: \(error.localizedDescription)")
            stops = []
        }
    }
    
    func clearAllStops() {
        stops.removeAll()
        saveStops()
    }
    
    // MARK: - Sample Data Helper
    func loadSampleData() {
        stops = TransportStop.sampleStops
        saveStops()
    }
    
    // MARK: - Validation
    func isStopIdUnique(_ stopId: String, excluding excludedId: UUID? = nil) -> Bool {
        return !stops.contains { stop in
            stop.stopId == stopId && stop.id != excludedId
        }
    }
}
