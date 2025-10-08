//
//  BusService.swift
//  tripPlanner
//
//  Created by Harlen Postill on 8/10/2025.
//

import Foundation

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
}

struct Location: Codable {
    let name: String
    let occupancy: String?
}

struct Transportation: Codable {
    let disassembledName: String
    let number: String
    let description: String
    let destination: Destination
    let colour: BusColour
}

struct Destination: Codable {
    let name: String
}

struct BusColour: Codable {
    let background: String
    let foreground: String
}

// MARK: - Bus Service
class BusService {
    static let shared = BusService()
    
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJteXpBdmt1bTgtZFd2cFpzWVBHNktkbm1YcXUxZVE5NEVFUDVaSmtkZ1JZIiwiaWF0IjoxNzU5ODk2NTU2fQ.PMO8FjOixsuvRvNN-K95xORKAMXt518A9YZ_BMLF80s"
    
    private init() {}
    
    func fetchDepartures(for stopId: String) async throws -> [StopEvent] {
        let urlString = buildAPIURL(for: stopId)
        guard let url = URL(string: urlString) else {
            throw BusServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BusServiceError.networkError
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(DepartureResponse.self, from: data)
        
        // Filter out cancelled buses and sort by departure time
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
    
    private func buildAPIURL(for stopId: String) -> String {
        let now = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: now)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HHmm"
        let timeString = timeFormatter.string(from: now)
        
        return "https://transportnsw.info/api/trip/v1/departure-list-request?date=\(dateString)&debug=false&depArrMacro=dep&depType=stopEvents&name=\(stopId)&time=\(timeString)&type=stop&excludedModes=2,9,11,1,4,7&accessible=null"
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
enum BusServiceError: Error, LocalizedError {
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
        guard let departureDate = BusService.shared.parseDate(departureTime) else {
            return "--"
        }
        
        let now = Date()
        let interval = departureDate.timeIntervalSince(now)
        let minutes = Int(interval / 60)
        
        if minutes < 0 {
            return "Due"
        } else if minutes == 0 {
            return "Now"
        } else if minutes < 60 {
            return "\(minutes) Mins"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
    }
    
    func delayStatus() -> String? {
        guard let plannedDate = BusService.shared.parseDate(departureTimePlanned),
              let actualDate = BusService.shared.parseDate(departureTime) else {
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
}
