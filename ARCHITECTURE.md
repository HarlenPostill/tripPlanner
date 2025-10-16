# Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           TRIP PLANNER APP                               │
│                     Location-Based Transport Tracking                    │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                              USER INTERFACE                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │
│  │  My Stops    │  │   Nearby     │  │  Settings    │                 │
│  │              │  │              │  │              │                 │
│  │ • List View  │  │ • Nearest    │  │ • Location   │                 │
│  │ • Add Stop   │  │   Stop       │  │   Status     │                 │
│  │ • Details    │  │ • Live       │  │ • Statistics │                 │
│  │ • Map Picker │  │   Departures │  │ • Data Mgmt  │                 │
│  └──────────────┘  └──────────────┘  └──────────────┘                 │
│         │                  │                  │                          │
└─────────┼──────────────────┼──────────────────┼──────────────────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          STATE MANAGEMENT                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌────────────────────────┐          ┌──────────────────────────┐      │
│  │    StopsManager        │          │   LocationManager        │      │
│  │    @Observable         │          │   @ObservableObject      │      │
│  ├────────────────────────┤          ├──────────────────────────┤      │
│  │ • stops: [Stop]        │◄────────►│ • location: CLLocation?  │      │
│  │ • busStops             │          │ • authorizationStatus    │      │
│  │ • lightRailStops       │          │ • isAuthorized           │      │
│  │                        │          │ • nearestStop            │      │
│  │ Methods:               │          │                          │      │
│  │ • addStop()            │          │ Methods:                 │      │
│  │ • deleteStop()         │          │ • requestPermission()    │      │
│  │ • updateStop()         │          │ • startUpdating()        │      │
│  │ • getStops()           │          │ • getNearestStop()       │      │
│  │ • saveStops()          │          │ • updateStops()          │      │
│  │ • loadStops()          │          │                          │      │
│  └────────────┬───────────┘          └────────────┬─────────────┘      │
│               │                                   │                     │
└───────────────┼───────────────────────────────────┼─────────────────────┘
                │                                   │
                │         ┌────────────┐            │
                └────────►│ Environment│◄───────────┘
                          │ Injection  │
                          └────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
┌───────────────┐      ┌────────────────┐     ┌──────────────┐
│ StopsListView │      │ NearbyView     │     │ SettingsView │
├───────────────┤      ├────────────────┤     ├──────────────┤
│ • Display all │      │ • Find nearest │     │ • Permissions│
│   stops       │      │ • Show         │     │ • Stats      │
│ • Sorted by   │      │   departures   │     │ • Clear data │
│   distance    │      │ • Auto-refresh │     │              │
└───────────────┘      └────────────────┘     └──────────────┘
        │
        ▼
┌───────────────┐
│ AddStopView   │
├───────────────┤
│ • Name input  │
│ • ID input    │
│ • Type picker │
│ • Map picker  │
│ • Validation  │
└───────┬───────┘
        │
        ▼
┌─────────────────┐
│ MapPickerView   │
├─────────────────┤
│ • MapKit        │
│ • Crosshair     │
│ • Coordinates   │
│ • Drag to place │
└─────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                          DATA PERSISTENCE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│                    ┌─────────────────────────────┐                      │
│                    │   App Group Container       │                      │
│                    │ group.com.hrln.tripPlanner  │                      │
│                    └────────────┬────────────────┘                      │
│                                 │                                        │
│                    ┌────────────▼────────────┐                          │
│                    │   UserDefaults Suite    │                          │
│                    ├─────────────────────────┤                          │
│                    │ Key: "savedTransportStops"│                        │
│                    │ Value: JSON [TransportStop]│                       │
│                    └────────────┬────────────┘                          │
│                                 │                                        │
│                ┌────────────────┼────────────────┐                      │
│                │                │                │                      │
│                ▼                ▼                ▼                      │
│         ┌──────────┐     ┌──────────┐    ┌──────────┐                 │
│         │   App    │     │  Widget  │    │  Widget  │                 │
│         │ Writes   │     │  Reads   │    │  Reads   │                 │
│         │  Stops   │     │  Stops   │    │  Stops   │                 │
│         └──────────┘     └──────────┘    └──────────┘                 │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                          WIDGET EXTENSION                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                  ConfigurationAppIntent                          │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ • mode: WidgetMode (.automatic | .manual)                       │  │
│  │ • transportType: TransportTypeAppEnum                           │  │
│  │ • stopId: String?                                               │  │
│  └────────────────────────────┬─────────────────────────────────────┘  │
│                                │                                        │
│                                ▼                                        │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    Provider (Timeline)                           │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │                                                                  │  │
│  │  IF mode == .automatic:                                         │  │
│  │    1. Get user location                                         │  │
│  │    2. Load stops from App Group                                 │  │
│  │    3. Find nearest stop of selected type                        │  │
│  │    4. Fetch departures for nearest stop                         │  │
│  │                                                                  │  │
│  │  IF mode == .manual:                                            │  │
│  │    1. Use configured stopId                                     │  │
│  │    2. Fetch departures for that stop                            │  │
│  │                                                                  │  │
│  │  Create timeline entries (every 2 minutes for 30 minutes)       │  │
│  └────────────────────────────┬─────────────────────────────────────┘  │
│                                │                                        │
│                                ▼                                        │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    SimpleEntry                                   │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ • date: Date                                                     │  │
│  │ • configuration: ConfigurationAppIntent                          │  │
│  │ • nextTransport: StopEvent?                                      │  │
│  │ • error: String?                                                 │  │
│  │ • stopName: String? (for automatic mode)                         │  │
│  └────────────────────────────┬─────────────────────────────────────┘  │
│                                │                                        │
│                                ▼                                        │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │           BusTrackerWidgetEntryView                              │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ • Transport number badge (colored)                               │  │
│  │ • Destination name                                               │  │
│  │ • Time until departure                                           │  │
│  │ • Stop name (if automatic mode)                                  │  │
│  │ • Delay status                                                   │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                        EXTERNAL SERVICES                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                  TransportService                                │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ • fetchDepartures(stopId, transportType) async throws           │  │
│  │ • buildAPIURL()                                                  │  │
│  │ • parseDate()                                                    │  │
│  └────────────────────────────┬─────────────────────────────────────┘  │
│                                │                                        │
│                                ▼                                        │
│                    Transport NSW API                                    │
│                    api.transportnsw.info                                │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                   CLLocationManager                              │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ • iOS Location Services                                          │  │
│  │ • Provides: CLLocation (lat/lng)                                 │  │
│  │ • Updates every 50+ meters                                       │  │
│  │ • Requires: Location permissions                                 │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                          DATA MODELS                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  TransportStop                     StopEvent (API Response)             │
│  ├─ id: UUID                       ├─ id: String                        │
│  ├─ name: String                   ├─ location: Location                │
│  ├─ stopId: String                 ├─ departureTime: String             │
│  ├─ stopType: StopType             ├─ transportation: Transportation    │
│  ├─ latitude: Double               ├─ isCancelled: Bool                 │
│  ├─ longitude: Double              ├─ isAccessible: Bool                │
│  ├─ createdAt: Date                └─ departureStatus: String?          │
│  └─ Methods:                                                             │
│     • distance(from:)                                                    │
│     • formattedDistance(from:)                                           │
│                                                                          │
│  StopType (Enum)                                                         │
│  ├─ bus                                                                  │
│  └─ lightRail                                                            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

WORKFLOW EXAMPLES:

1. USER ADDS A STOP:
   User Input → AddStopView → Validate with API → StopsManager.addStop()
   → Save to UserDefaults (App Group) → Update UI → Widget can access

2. WIDGET SHOWS NEAREST STOP (Automatic Mode):
   Widget Loads → Get Location → Load Stops from App Group → Calculate Distances
   → Find Nearest → Fetch Departures → Display in Widget

3. USER VIEWS NEARBY DEPARTURES:
   Nearby Tab → LocationManager.location → StopsManager.stops
   → Calculate Nearest → Fetch from API → Display List

4. LOCATION UPDATE:
   CLLocationManager → LocationManager.location (published)
   → SwiftUI observes → UI updates → Distances recalculated

KEY DESIGN DECISIONS:

✓ @Observable for StopsManager (modern SwiftUI state)
✓ @ObservableObject for LocationManager (CLLocationManager delegate)
✓ App Group for data sharing (app ↔ widget)
✓ Codable for JSON persistence
✓ async/await for API calls
✓ Environment injection for dependency management
✓ Separation of concerns (UI, State, Services, Data)
✓ Type-safe models with validation
✓ Error handling at every layer
✓ Privacy-first location usage
