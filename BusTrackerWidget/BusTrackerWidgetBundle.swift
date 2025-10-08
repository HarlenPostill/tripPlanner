//
//  BusTrackerWidgetBundle.swift
//  BusTrackerWidget
//
//  Created by Harlen Postill on 8/10/2025.
//

import WidgetKit
import SwiftUI

@main
struct BusTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        BusTrackerWidget()
        BusTrackerWidgetControl()
        BusTrackerWidgetLiveActivity()
    }
}
