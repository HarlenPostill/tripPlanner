# Trip Planner - Location-Based Transport Tracking

## Overview
This app has been completely redesigned to support location-based transport tracking. Users can now save multiple bus and light rail stops with their locations, and the widget will automatically show the nearest stop based on the user's current location.

## New Features

### 1. **Location-Based Stop Management**
- Save multiple bus and light rail stops with their exact coordinates
- Each stop includes: name, stop ID, transport type, and location
- Stops are persisted using App Groups for sharing between app and widget

### 2. **Smart Widget**
- **Automatic Mode**: Widget automatically displays the nearest stop based on user location
- **Manual Mode**: Widget can be configured to always show a specific stop
- Updates every 2 minutes with fresh departure data

### 3. **Comprehensive UI**
- **My Stops Tab**: View, add, edit, and delete saved stops
- **Nearby Tab**: See real-time departures from your nearest stop
- **Settings Tab**: Manage permissions and app data

### 4. **Map Integration**
- Visual map picker for selecting stop locations
- Shows stop distances from your current location
- Map preview in stop detail view

## Setup Instructions

### Step 1: Configure App Group
1. Open the Xcode project
2. Select the **tripPlanner** target
3. Go to **Signing & Capabilities**
4. Click **+ Capability** and add **App Groups**
5. Enable the app group: `group.com.hrln.tripPlanner`
6. Repeat for the **BusTrackerWidgetExtension** target

### Step 2: Add Location Permissions to Main App
1. Select the **tripPlanner** target
2. Go to **Info** tab
3. Add the following keys:
   - **Privacy - Location When In Use Usage Description**
     - Value: `This app uses your location to find the nearest transport stops and show real-time departure information.`
   - **Privacy - Location Always and When In Use Usage Description**
     - Value: `This app uses your location to keep widgets updated with the nearest transport stop departures.`

### Step 3: Update App Entry Point
Replace the current app entry point with the new one:

```swift
import SwiftUI

@main
struct TransportTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            NewContentView()
        }
    }
}
```

### Step 4: Add Files to Targets
Make sure all new files are added to the correct targets in Xcode:

**Main App Target (tripPlanner):**
- Models/TransportStop.swift
- Managers/LocationManager.swift
- Managers/StopsManager.swift
- Views/StopsListView.swift
- Views/AddStopView.swift
- Views/StopDetailView.swift
- Views/MapPickerView.swift
- NewContentView.swift

**Widget Target (BusTrackerWidgetExtension):**
- SharedModels.swift
- Updated BusTrackerWidget.swift
- Updated AppIntent.swift

## Architecture

### Data Models
- **TransportStop**: Represents a saved transport stop with location
- **StopType**: Enum for Bus/LightRail types
- **Location & Transport Models**: Existing API response models

### Managers
- **StopsManager**: @Observable class managing stop CRUD operations and persistence
- **LocationManager**: ObservableObject managing location updates and nearest stop calculations
- **TransportService**: Existing service for API calls

### Views
- **StopsListView**: Displays all saved stops, sorted by distance
- **AddStopView**: Form for adding new stops with map picker
- **StopDetailView**: Shows stop details and live departures
- **MapPickerView**: Interactive map for selecting stop coordinates
- **NearbyDeparturesView**: Shows departures from nearest stop
- **SettingsView**: App configuration and data management

### Widget
- **Provider**: Updated to support automatic (location-based) and manual modes
- **ConfigurationAppIntent**: Enhanced with WidgetMode enum
- **SharedModels**: Lightweight version of data models for widget use

## Usage Guide

### Adding a Stop
1. Go to "My Stops" tab
2. Tap the + button
3. Enter stop name and ID
4. Select transport type (Bus/Light Rail)
5. Choose location:
   - Use current location, OR
   - Select on map by moving the map to position the crosshair
6. Tap "Add Stop" (validates against API)

### Configuring Widgets
1. Long press the widget
2. Select "Edit Widget"
3. Choose mode:
   - **Automatic**: Shows nearest stop (requires location access)
   - **Manual**: Shows specific stop ID
4. Select transport type
5. Tap outside to save

### Viewing Nearby Departures
1. Go to "Nearby" tab
2. Grant location access if prompted
3. Select Bus or Light Rail
4. View real-time departures from nearest stop
5. Tap refresh to update

## Data Sharing

All stop data is stored in an App Group container (`group.com.hrln.tripPlanner`) using UserDefaults. This allows:
- The main app to manage stops
- Widgets to access stop data
- Consistent data across app and all widgets

## Location Privacy

The app follows best practices for location privacy:
- Only requests "When In Use" permission
- Clear usage descriptions
- Widget-specific location flag (`NSWidgetWantsLocation`)
- Location updates only when needed
- Efficient distance filtering (updates every 50 meters)

## API Validation

When adding stops, the app validates the stop ID by attempting to fetch departures from the Transport NSW API. This ensures:
- Stop IDs are valid
- Transport type matches the stop
- Immediate feedback to users

## Best Practices Implemented

1. **SwiftUI Observable Framework**: Using @Observable macro for StopsManager
2. **Environment Objects**: Proper dependency injection for managers
3. **Async/Await**: Modern concurrency for network calls
4. **MainActor**: Proper UI updates on main thread
5. **Error Handling**: Comprehensive error messages and validation
6. **Codable**: Type-safe JSON encoding/decoding
7. **CLLocation**: Native location services integration
8. **MapKit**: Modern Map API with SwiftUI

## Testing Checklist

- [ ] Location permission flow works correctly
- [ ] Stops can be added, viewed, edited, and deleted
- [ ] Map picker selects accurate coordinates
- [ ] Widget updates in automatic mode
- [ ] Widget works in manual mode
- [ ] Nearest stop calculation is accurate
- [ ] Departures display correctly
- [ ] App Group data sharing works
- [ ] Widget configuration persists
- [ ] Location updates efficiently

## Known Limitations

1. Widget location access requires iOS 17+ for optimal functionality
2. Location-based widgets may have delayed updates due to iOS widget refresh policies
3. Stop ID validation requires network connection
4. Map picker requires location permission for "current location" feature

## Future Enhancements

- [ ] Search for stops by name or ID
- [ ] Import stops from favorites/recent searches
- [ ] Multi-stop route planning
- [ ] Push notifications for departures
- [ ] Apple Watch complication
- [ ] Live Activities for upcoming departures
- [ ] Offline mode with cached data
- [ ] Export/import stop lists

## Troubleshooting

### Widget not updating with location
- Ensure "NSWidgetWantsLocation" is in widget Info.plist
- Check location permissions are granted
- Verify App Group is configured correctly
- Try removing and re-adding the widget

### Stops not syncing between app and widget
- Check App Group identifier matches in both targets
- Verify both targets have App Group capability enabled
- Try clearing and re-adding stops

### Location not working
- Check Info.plist has location usage descriptions
- Verify location permissions in Settings
- Ensure LocationManager is in environment
- Check device location services are enabled

## Support

For issues or questions, check the code comments or review the SwiftUI best practices documentation.
