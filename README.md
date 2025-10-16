# 🚍 Trip Planner - Location-Based Transport Tracker

A SwiftUI app for tracking NSW bus and light rail departures with intelligent location-based stop selection.

## 🌟 Features

### 📍 Location-Based Tracking
- Automatically finds your nearest bus or light rail stop
- Save multiple stops with precise GPS coordinates
- Real-time distance calculations
- Privacy-focused location usage

### 🔔 Smart Widgets
- **Automatic Mode**: Shows departures from your nearest saved stop
- **Manual Mode**: Display a specific stop of your choice
- Updates every 2 minutes
- Supports both Bus and Light Rail

### 🗺️ Comprehensive Stop Management
- Add stops with interactive map picker
- Validate stop IDs against live transport data
- View live departure information for any stop
- Edit and organize your saved stops
- Sort by distance from current location

### 📱 Modern SwiftUI Architecture
- Built with latest SwiftUI best practices
- @Observable state management
- async/await for network calls
- App Groups for widget data sharing
- CoreLocation integration
- MapKit for location selection

## 🚀 Quick Start

### Prerequisites
- Xcode 16.0+
- iOS 17.0+
- Valid Transport NSW API key (already configured)
- Physical device or simulator with location services

### Setup (5-10 minutes)

**Important**: You MUST complete these setup steps before the app will work correctly!

1. **Clone and Open**
   ```bash
   cd tripPlanner
   open tripPlanner.xcodeproj
   ```

2. **Configure App Groups** (CRITICAL)
   - See `SETUP_CHECKLIST.md` for detailed steps
   - Add App Group `group.com.hrln.tripPlanner` to BOTH targets
   - Main app target: `tripPlanner`
   - Widget target: `BusTrackerWidgetExtension`

3. **Add Location Permissions**
   - See `INFO_PLIST_SETUP.md` for exact steps
   - Add location usage descriptions to main app Info.plist
   - Widget Info.plist already configured

4. **Build and Run**
   - Select your device or simulator
   - Build both schemes: `tripPlanner` and `BusTrackerWidgetExtension`
   - Run the app

### First Use

1. **Grant Location Permission**
   - Tap "Nearby" tab or try to add a stop
   - Tap "Allow While Using App"

2. **Add Your First Stop**
   - Go to "My Stops" tab
   - Tap the + button
   - Enter stop details (name, ID, type)
   - Select location (current or on map)
   - Tap "Add Stop"

3. **Add the Widget**
   - Go to home screen
   - Long press to enter jiggle mode
   - Tap + in top corner
   - Search "Trip Planner" or "Transport Tracker"
   - Add small widget
   - Long press widget → "Edit Widget"
   - Choose Automatic or Manual mode
   - Select transport type

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| `SETUP_CHECKLIST.md` | Step-by-step setup instructions with checkboxes |
| `COMPLETE_SUMMARY.md` | Comprehensive feature overview and implementation details |
| `IMPLEMENTATION_GUIDE.md` | Detailed technical documentation |
| `INFO_PLIST_SETUP.md` | Xcode configuration guide for Info.plist |
| `ARCHITECTURE.md` | System architecture and data flow diagrams |

## 🏗️ Project Structure

```
tripPlanner/
├── Models/
│   └── TransportStop.swift          # Stop data model
├── Managers/
│   ├── LocationManager.swift        # Location services
│   └── StopsManager.swift           # Stop persistence & CRUD
├── Views/
│   ├── StopsListView.swift          # List of saved stops
│   ├── AddStopView.swift            # Add new stop form
│   ├── StopDetailView.swift         # Stop details & departures
│   └── MapPickerView.swift          # Interactive map picker
├── NewContentView.swift             # Main app with tabs
├── tripPlannerApp.swift             # App entry point
└── BusService.swift                 # Existing transport API service

BusTrackerWidget/
├── SharedModels.swift               # Shared data models for widget
├── AppIntent.swift                  # Widget configuration
├── BusTrackerWidget.swift           # Widget UI and timeline
└── Info.plist                       # Widget permissions
```

## 🎯 Usage Examples

### Adding a Stop
```
1. Tap "My Stops" → "+"
2. Enter: "Central Station" / "203294" / Light Rail
3. Tap "Use Current Location" or map
4. Tap "Add Stop"
5. Stop validated against API
6. Appears in list with distance
```

### Viewing Nearby Departures
```
1. Tap "Nearby" tab
2. Select "Bus" or "Light Rail"
3. See nearest stop automatically
4. View real-time departures
5. Pull to refresh
```

### Configuring Widget
```
1. Long press widget
2. "Edit Widget"
3. Mode: Automatic
4. Type: Bus
5. Tap outside to save
6. Widget shows nearest bus stop
```

## 🔧 Technical Details

### State Management
- **StopsManager**: @Observable for stop CRUD operations
- **LocationManager**: ObservableObject wrapping CLLocationManager
- Environment injection for dependency management

### Data Persistence
- App Group: `group.com.hrln.tripPlanner`
- UserDefaults with suite name
- JSON encoding/decoding
- Automatic sync between app and widgets

### Location Services
- "When In Use" permission only
- Updates every 50+ meters (efficient)
- Widget-specific location flag
- Nearest stop calculation using CoreLocation

### API Integration
- Transport NSW API v1
- Async/await network calls
- Error handling and validation
- Stop ID verification on add

### SwiftUI Best Practices
- @Observable macro (iOS 17+)
- @Environment for injection
- @MainActor for UI updates
- Codable for JSON
- Type-safe models
- Proper error handling

## 🧪 Testing

See `SETUP_CHECKLIST.md` for comprehensive testing checklist covering:
- Location permissions
- Stop management (add/edit/delete)
- Widget automatic mode
- Widget manual mode
- Nearby departures
- Data synchronization
- Error handling

## 🐛 Troubleshooting

### Widget Not Showing Nearest Stop
- ✓ Check App Group is configured in both targets
- ✓ Verify location permission granted
- ✓ Ensure widget has `NSWidgetWantsLocation` in Info.plist
- ✓ Try removing and re-adding widget

### Stops Not Syncing
- ✓ Confirm App Group identifier matches exactly
- ✓ Rebuild both targets
- ✓ Check both targets have App Group capability

### Location Not Working
- ✓ Info.plist has location usage descriptions
- ✓ Location permission granted in Settings
- ✓ Device location services enabled
- ✓ LocationManager in environment

See `COMPLETE_SUMMARY.md` for more troubleshooting tips.

## 📱 Requirements

- iOS 17.0+
- Xcode 16.0+
- Swift 5.9+
- Device with location services (or simulator)
- Network connection for API calls

## 🎨 UI Components

### Main App
- Tab-based navigation (3 tabs)
- List views with search/filter
- Forms with validation
- Interactive maps
- Pull-to-refresh
- Empty states
- Error states

### Widget
- Small size (system small)
- Accessory rectangular
- Dynamic color badges
- Real-time updates
- Configuration UI

## 🔐 Privacy

- Location only "When In Use"
- Clear usage descriptions
- No background tracking
- Widget location opt-in
- User controls all data
- No analytics or tracking

## 🚦 API Limits

- Transport NSW API rate limits apply
- Widget updates every 2 minutes
- Manual refresh available
- Cached in timeline for 30 minutes

## 📝 License

This project is for personal/educational use with Transport NSW public API.

## 🙏 Acknowledgments

- Transport NSW for public API
- SwiftUI framework and documentation
- CoreLocation and MapKit frameworks

## 📞 Support

For setup help, see:
1. `SETUP_CHECKLIST.md` - Step-by-step setup
2. `COMPLETE_SUMMARY.md` - Troubleshooting
3. Code comments in source files

## 🔄 Version History

### v2.0 (Current) - Location-Based
- ✅ Multiple stop management
- ✅ Location-based nearest stop
- ✅ Automatic/manual widget modes
- ✅ Map picker for stop locations
- ✅ Comprehensive UI redesign
- ✅ App Group data sharing
- ✅ Modern SwiftUI architecture

### v1.0 - Original
- Single hardcoded stop
- Basic widget
- Simple departure list

---

**Ready to track your transport?** Follow the `SETUP_CHECKLIST.md` to get started! 🚀
