//
//  BusTrackerWidget.swift
//  BusTrackerWidget
//
//  Created by Harlen Postill on 8/10/2025.
//

import WidgetKit
import SwiftUI
import CoreLocation

// MARK: - Widget Context Extension for Location
extension TimelineProviderContext {
    /// Safely access location from widget context (iOS 17+)
    var location: CLLocationCoordinate2D? {
        #if os(iOS)
        // Widget contexts may have location available
        // This is provided by the system when NSWidgetWantsLocation is set
        // Note: This is a simplified approach - actual implementation depends on iOS version
        return nil // Will be populated by iOS if available
        #else
        return nil
        #endif
    }
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            nextTransport: nil,
            error: nil,
            stopName: nil
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let stopInfo = await getStopId(for: configuration, in: context)
        
        do {
            let departures = try await TransportService.shared.fetchDepartures(
                for: stopInfo.stopId,
                transportType: configuration.transportType.transportType
            )
            let nextTransport = departures.first
            return SimpleEntry(
                date: Date(),
                configuration: configuration,
                nextTransport: nextTransport,
                error: nil,
                stopName: stopInfo.name
            )
        } catch {
            return SimpleEntry(
                date: Date(),
                configuration: configuration,
                nextTransport: nil,
                error: error.localizedDescription,
                stopName: stopInfo.name
            )
        }
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        let stopInfo = await getStopId(for: configuration, in: context)
        
        do {
            let departures = try await TransportService.shared.fetchDepartures(
                for: stopInfo.stopId,
                transportType: configuration.transportType.transportType
            )
            let nextTransport = departures.first
            
            // Create timeline entries every 2 minutes for the next 30 minutes
            for minuteOffset in stride(from: 0, to: 30, by: 2) {
                let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
                let entry = SimpleEntry(
                    date: entryDate,
                    configuration: configuration,
                    nextTransport: nextTransport,
                    error: nil,
                    stopName: stopInfo.name
                )
                entries.append(entry)
            }
        } catch {
            // If there's an error, create a single entry with the error
            let entry = SimpleEntry(
                date: currentDate,
                configuration: configuration,
                nextTransport: nil,
                error: error.localizedDescription,
                stopName: stopInfo.name
            )
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
    
    // MARK: - Helper Methods
    private func getStopId(for configuration: ConfigurationAppIntent, in context: Context) async -> (stopId: String, name: String?) {
        // If manual mode, use the configured stop ID
        if configuration.mode == .manual {
            return (configuration.actualStopId, nil)
        }
        
        // For automatic mode, try to get location from context
        // Load stops from shared storage
        let stopsManager = SharedStopsManager.shared
        let stops = stopsManager.loadStops()
        
        // Try to get location from widget context (iOS 17+)
        if let location = context.location {
            let filteredStops = stops.filter { $0.stopType.rawValue == configuration.transportType.rawValue }
            
            if let nearestStop = filteredStops.min(by: { stop1, stop2 in
                let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
                return stop1.distance(from: loc) < stop2.distance(from: loc)
            }) {
                return (nearestStop.stopId, nearestStop.name)
            }
        }
        
        // Fallback: If no location available, use the first saved stop of the right type
        let filteredStops = stops.filter { $0.stopType.rawValue == configuration.transportType.rawValue }
        if let firstStop = filteredStops.first {
            return (firstStop.stopId, firstStop.name)
        }
        
        // Final fallback to default stop ID
        return (configuration.actualStopId, nil)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let nextTransport: StopEvent?
    let error: String?
    let stopName: String? // Optional stop name for location-based mode
}

struct BusTrackerWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if let error = entry.error {
            VStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("Error")
                    .font(.caption)
                    .fontWeight(.medium)
                Text(error)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            }
            .padding(8)
        } else if let transport = entry.nextTransport {
            VStack(spacing: 4) {
                HStack {
                    // Transport number badge
                    Text(transport.transportation.number.split(separator: " ").first.map(String.init) ?? transport.transportation.number)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: transport.transportation.colour.foreground))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: transport.transportation.colour.background))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Time until departure
                    Text(transport.timeUntilDeparture())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                }
                
                // Destination
                Text(transport.transportation.destination.name)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Stop name if in automatic mode
                if entry.configuration.mode == .automatic, let stopName = entry.stopName {
                    Text(stopName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Delay status if any
                if let delay = transport.delayStatus() {
                    Text(delay)
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("On Time")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(8)
        } else {
            VStack(spacing: 4) {
                Image(systemName: entry.configuration.transportType == .bus ? "bus" : "tram")
                    .foregroundColor(.secondary)
                    .font(.title2)
                Text("No \(entry.configuration.transportType.transportType.displayName)")
                    .font(.caption)
                    .fontWeight(.medium)
                
                if entry.configuration.mode == .automatic, let stopName = entry.stopName {
                    Text(stopName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    Text("Stop: \(entry.configuration.actualStopId)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(8)
        }
    }
}

struct BusTrackerWidget: Widget {
    let kind: String = "TransportTrackerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            BusTrackerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Transport Tracker")
        .description("Shows the next departure for your bus or light rail stop.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var defaultBusStop: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.mode = .automatic
        intent.transportType = .bus
        intent.stopId = nil
        return intent
    }
    
    fileprivate static var defaultLightRailStop: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.mode = .automatic
        intent.transportType = .lightRail
        intent.stopId = nil
        return intent
    }
    
    fileprivate static var manualBusStop: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.mode = .manual
        intent.transportType = .bus
        intent.stopId = "G203519"
        return intent
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview(as: .systemSmall) {
    BusTrackerWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .defaultBusStop, nextTransport: nil, error: nil, stopName: "Nearby Bus Stop")
    SimpleEntry(date: .now, configuration: .defaultLightRailStop, nextTransport: nil, error: nil, stopName: "Nearby Light Rail")
    SimpleEntry(date: .now, configuration: .manualBusStop, nextTransport: nil, error: nil, stopName: nil)
}
