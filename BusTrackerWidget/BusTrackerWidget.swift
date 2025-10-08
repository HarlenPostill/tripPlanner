//
//  BusTrackerWidget.swift
//  BusTrackerWidget
//
//  Created by Harlen Postill on 8/10/2025.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            nextTransport: nil,
            error: nil
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        do {
            let departures = try await TransportService.shared.fetchDepartures(for: configuration.actualStopId, transportType: configuration.transportType.transportType)
            let nextTransport = departures.first
            return SimpleEntry(
                date: Date(),
                configuration: configuration,
                nextTransport: nextTransport,
                error: nil
            )
        } catch {
            return SimpleEntry(
                date: Date(),
                configuration: configuration,
                nextTransport: nil,
                error: error.localizedDescription
            )
        }
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        do {
            let departures = try await TransportService.shared.fetchDepartures(for: configuration.actualStopId, transportType: configuration.transportType.transportType)
            let nextTransport = departures.first
            
            // Create timeline entries every 2 minutes for the next 30 minutes
            for minuteOffset in stride(from: 0, to: 30, by: 2) {
                let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
                let entry = SimpleEntry(
                    date: entryDate,
                    configuration: configuration,
                    nextTransport: nextTransport,
                    error: nil
                )
                entries.append(entry)
            }
        } catch {
            // If there's an error, create a single entry with the error
            let entry = SimpleEntry(
                date: currentDate,
                configuration: configuration,
                nextTransport: nil,
                error: error.localizedDescription
            )
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let nextTransport: StopEvent?
    let error: String?
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
                Text("Stop: \(entry.configuration.actualStopId)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
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
        intent.transportType = .bus
        intent.stopId = "G203519"
        return intent
    }
    
    fileprivate static var defaultLightRailStop: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.transportType = .lightRail
        intent.stopId = "203294"
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
    SimpleEntry(date: .now, configuration: .defaultBusStop, nextTransport: nil, error: nil)
    SimpleEntry(date: .now, configuration: .defaultLightRailStop, nextTransport: nil, error: nil)
}
