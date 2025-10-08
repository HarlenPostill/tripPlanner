//
//  BusService.swift
//  BusTrackerWidget
//
//  Created by Harlen Postill on 8/10/2025.
//

import Foundation

// MARK: - Transport Type
enum TransportType: String, CaseIterable, Identifiable {
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
    
    var defaultStopId: String {
        switch self {
        case .bus:
            return "G203519"
        case .lightRail:
            return "203294"
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

// MARK: - Models (shared between app and widget)
struct DepartureResponse: Codable {
    let stopEvents: [StopEvent]
}

struct StopEvent: Codable, Identifiable {
    let id: String
    let location: Location
    let departureTime: String
    let departureTimePlanned: String
    let departureTimeEstimated: String?
    let departureStatus: String?
    let transportation: Transportation
    let isCancelled: Bool
    let isAccessible: Bool
    
    // Additional properties for light rail
    let arrivalTimePlanned: String?
    let arrivalTimeEstimated: String?
    let arrivalStatus: String?
    let isHighFrequency: Bool?
    
    // Custom initializer to handle missing properties
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        location = try container.decode(Location.self, forKey: .location)
        departureTime = try container.decode(String.self, forKey: .departureTime)
        departureTimePlanned = try container.decode(String.self, forKey: .departureTimePlanned)
        departureTimeEstimated = try container.decodeIfPresent(String.self, forKey: .departureTimeEstimated)
        departureStatus = try container.decodeIfPresent(String.self, forKey: .departureStatus)
        transportation = try container.decode(Transportation.self, forKey: .transportation)
        isCancelled = try container.decode(Bool.self, forKey: .isCancelled)
        isAccessible = try container.decode(Bool.self, forKey: .isAccessible)
        
        // Optional properties for light rail
        arrivalTimePlanned = try container.decodeIfPresent(String.self, forKey: .arrivalTimePlanned)
        arrivalTimeEstimated = try container.decodeIfPresent(String.self, forKey: .arrivalTimeEstimated)
        arrivalStatus = try container.decodeIfPresent(String.self, forKey: .arrivalStatus)
        isHighFrequency = try container.decodeIfPresent(Bool.self, forKey: .isHighFrequency)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, location, departureTime, departureTimePlanned, departureTimeEstimated
        case departureStatus, transportation, isCancelled, isAccessible
        case arrivalTimePlanned, arrivalTimeEstimated, arrivalStatus, isHighFrequency
    }
}

struct Location: Codable {
    let name: String
    let occupancy: String?
    
    // Custom initializer to handle different location structures
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        occupancy = try container.decodeIfPresent(String.self, forKey: .occupancy)
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, occupancy
    }
}

struct Transportation: Codable {
    let disassembledName: String
    let number: String
    let description: String
    let destination: Destination
    let colour: TransportColour
    
    // Custom initializer to handle different transportation structures
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        disassembledName = try container.decode(String.self, forKey: .disassembledName)
        description = try container.decode(String.self, forKey: .description)
        destination = try container.decode(Destination.self, forKey: .destination)
        colour = try container.decode(TransportColour.self, forKey: .colour)
        
        // Handle different number field formats
        if let numberValue = try? container.decode(String.self, forKey: .number) {
            number = numberValue
        } else {
            // For light rail, use disassembledName as number
            number = disassembledName
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case disassembledName, number, description, destination, colour
    }
}

struct Destination: Codable {
    let name: String
}

struct TransportColour: Codable {
    let background: String
    let foreground: String
    
    // Handle the "text" field that light rail might have
    let text: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        background = try container.decode(String.self, forKey: .background)
        foreground = try container.decode(String.self, forKey: .foreground)
        text = try container.decodeIfPresent(String.self, forKey: .text)
    }
    
    private enum CodingKeys: String, CodingKey {
        case background, foreground, text
    }
}

// MARK: - Transport Service
class TransportService {
    static let shared = TransportService()
    
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJteXpBdmt1bTgtZFd2cFpzWVBHNktkbm1YcXUxZVE5NEVFUDVaSmtkZ1JZIiwiaWF0IjoxNzU5ODk2NTU2fQ.PMO8FjOixsuvRvNN-K95xORKAMXt518A9YZ_BMLF80s"
    
    private init() {}
    
    func fetchDepartures(for stopId: String, transportType: TransportType) async throws -> [StopEvent] {
        let urlString = buildAPIURL(for: stopId, transportType: transportType)
        guard let url = URL(string: urlString) else {
            throw TransportServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TransportServiceError.networkError
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(DepartureResponse.self, from: data)
        
        // Filter out cancelled departures and sort by departure time
        let activeDepartures = result.stopEvents
            .filter { !$0.isCancelled }
            .sorted { departure1, departure2 in
                guard let date1 = parseDate(departure1.departureTime),
                      let date2 = parseDate(departure2.departureTime) else {
                    return false
                }
                return date1 < date2
            }
        
        return activeDepartures
    }
    
    private func buildAPIURL(for stopId: String, transportType: TransportType) -> String {
        let now = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: now)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HHmm"
        let timeString = timeFormatter.string(from: now)
        
        return "https://transportnsw.info/api/trip/v1/departure-list-request?date=\(dateString)&debug=false&depArrMacro=dep&depType=stopEvents&name=\(stopId)&time=\(timeString)&type=\(transportType.urlType)&excludedModes=\(transportType.excludedModes)&accessible=null"
    }
    
    func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        // Fallback: try without fractional seconds
        let simpleFormatter = ISO8601DateFormatter()
        simpleFormatter.formatOptions = [.withInternetDateTime]
        simpleFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return simpleFormatter.date(from: dateString)
    }
}

// MARK: - Error Handling
enum TransportServiceError: Error, LocalizedError {
    case invalidURL
    case networkError
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError:
            return "Network error"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

// MARK: - Helper Extensions
extension StopEvent {
    func timeUntilDeparture() -> String {
        guard let departureDate = TransportService.shared.parseDate(departureTime) else {
            return "--"
        }
        
        let now = Date()
        let interval = departureDate.timeIntervalSince(now)
        let minutes = Int(interval / 60)
        
        if minutes < 0 {
            return "Due"
        } else if minutes == 0 {
            return "Now"
        } else if minutes == 1 {
            return "1 Min"
        } else if minutes < 60 {
            return "\(minutes) Mins"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
    }
    
    func delayStatus() -> String? {
        guard let plannedDate = TransportService.shared.parseDate(departureTimePlanned),
              let actualDate = TransportService.shared.parseDate(departureTime) else {
            return nil
        }
        
        let delaySeconds = actualDate.timeIntervalSince(plannedDate)
        let delayMinutes = Int(delaySeconds / 60)
        
        if delayMinutes > 0 {
            return "Late \(delayMinutes) mins"
        } else if delayMinutes < -1 {
            return "Early \(abs(delayMinutes)) mins"
        } else if departureStatus?.lowercased() == "late" {
            return "Running late"
        }
        
        return nil
    }
    
    func transportTypeDisplayName() -> String {
        // Determine transport type based on the transportation data
        if transportation.disassembledName.contains("L") && transportation.description.contains("Light Rail") {
            return "Light Rail"
        } else {
            return "Bus"
        }
    }
}

// MARK: - Backwards Compatibility
typealias BusService = TransportService
typealias BusServiceError = TransportServiceError
typealias BusColour = TransportColour
