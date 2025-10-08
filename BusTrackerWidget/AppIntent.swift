//
//  AppIntent.swift
//  BusTrackerWidget
//
//  Created by Harlen Postill on 8/10/2025.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Bus Stop Configuration" }
    static var description: IntentDescription { "Configure which bus stop to track." }

    // Bus stop ID parameter
    @Parameter(title: "Bus Stop ID", default: "G203519")
    var busStopId: String
}
