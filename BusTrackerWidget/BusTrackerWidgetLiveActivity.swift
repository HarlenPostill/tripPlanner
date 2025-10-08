//
//  BusTrackerWidgetLiveActivity.swift
//  BusTrackerWidget
//
//  Created by Harlen Postill on 8/10/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BusTrackerWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BusTrackerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BusTrackerWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension BusTrackerWidgetAttributes {
    fileprivate static var preview: BusTrackerWidgetAttributes {
        BusTrackerWidgetAttributes(name: "World")
    }
}

extension BusTrackerWidgetAttributes.ContentState {
    fileprivate static var smiley: BusTrackerWidgetAttributes.ContentState {
        BusTrackerWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BusTrackerWidgetAttributes.ContentState {
         BusTrackerWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BusTrackerWidgetAttributes.preview) {
   BusTrackerWidgetLiveActivity()
} contentStates: {
    BusTrackerWidgetAttributes.ContentState.smiley
    BusTrackerWidgetAttributes.ContentState.starEyes
}
