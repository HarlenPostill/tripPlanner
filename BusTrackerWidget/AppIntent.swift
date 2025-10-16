//
//  AppIntent.swift
//  BusTrackerWidget
//
//  Created by Harlen Postill on 8/10/2025.
//

import WidgetKit
import AppIntents
import CoreLocation

// MARK: - Widget Configuration Mode
enum WidgetMode: String, AppEnum {
    case automatic = "automatic"
    case manual = "manual"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Widget Mode"
    
    static var caseDisplayRepresentations: [WidgetMode: DisplayRepresentation] = [
        .automatic: "Nearest Stop (Location-based)",
        .manual: "Manual Stop Selection"
    ]
}

// MARK: - Configuration Intent
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Transport Configuration" }
    static var description: IntentDescription { "Configure which transport stop to track." }

    // Mode selection
    @Parameter(title: "Mode", default: .automatic)
    var mode: WidgetMode
    
    // Transport type parameter
    @Parameter(title: "Transport Type", default: .bus)
    var transportType: TransportTypeAppEnum
    
    // Stop ID parameter (will be set based on transport type or location)
    @Parameter(title: "Stop ID")
    var stopId: String?
    
    init() {
        mode = .automatic
        transportType = .bus
        stopId = nil
    }
    
    init(mode: WidgetMode, transportType: TransportTypeAppEnum, stopId: String?) {
        self.mode = mode
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
