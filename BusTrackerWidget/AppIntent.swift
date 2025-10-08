//
//  AppIntent.swift
//  BusTrackerWidget
//
//  Created by Harlen Postill on 8/10/2025.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Transport Configuration" }
    static var description: IntentDescription { "Configure which transport stop to track." }

    // Transport type parameter
    @Parameter(title: "Transport Type", default: .bus)
    var transportType: TransportTypeAppEnum
    
    // Stop ID parameter (will be set based on transport type)
    @Parameter(title: "Stop ID")
    var stopId: String?
    
    init() {
        transportType = .bus
        stopId = TransportType.bus.defaultStopId
    }
    
    init(transportType: TransportTypeAppEnum, stopId: String?) {
        self.transportType = transportType
        self.stopId = stopId
    }
    
    // Helper property to get the actual stop ID to use
    var actualStopId: String {
        return stopId ?? transportType.transportType.defaultStopId
    }
}

// App Intent compatible enum for transport types
enum TransportTypeAppEnum: String, AppEnum, CaseIterable {
    case bus = "bus"
    case lightRail = "lightRail"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Transport Type")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .bus: "Bus",
        .lightRail: "Light Rail"
    ]
    
    var transportType: TransportType {
        switch self {
        case .bus:
            return .bus
        case .lightRail:
            return .lightRail
        }
    }
}
