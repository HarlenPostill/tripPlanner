# Required Info.plist Configuration

## Main App (tripPlanner target)

You need to add these keys to your main app's Info.plist or configure them in the Target's Info tab in Xcode:

### Method 1: Using Xcode UI
1. Select the **tripPlanner** target
2. Go to the **Info** tab
3. Click the **+** button to add new entries:

**Key 1:**
- **Key**: Privacy - Location When In Use Usage Description
- **Type**: String
- **Value**: `This app uses your location to find the nearest transport stops and show real-time departure information.`

**Key 2:**
- **Key**: Privacy - Location Always and When In Use Usage Description  
- **Type**: String
- **Value**: `This app uses your location to keep widgets updated with the nearest transport stop departures.`

### Method 2: Edit Info.plist directly

If your project has an Info.plist file in the tripPlanner folder, add these entries:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses your location to find the nearest transport stops and show real-time departure information.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app uses your location to keep widgets updated with the nearest transport stop departures.</string>
```

## Widget Extension (BusTrackerWidgetExtension target)

The widget's Info.plist has already been updated with:

```xml
<key>NSWidgetWantsLocation</key>
<true/>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This widget uses your location to show departures from the nearest transport stop.</string>
```

## App Groups Configuration

### For BOTH targets (tripPlanner AND BusTrackerWidgetExtension):

1. Select the target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Select **App Groups**
5. Click the **+** button in the App Groups section
6. Enter: `group.com.hrln.tripPlanner`
7. Make sure the checkbox is checked

**Important**: The App Group identifier must be **exactly the same** for both targets.

## Verification

After configuration, verify:
- [ ] Location permission appears when launching the app
- [ ] Widget Info.plist includes NSWidgetWantsLocation
- [ ] Both targets have the same App Group enabled
- [ ] Location usage descriptions are clear and user-friendly

## Testing Location Permissions

1. Build and run the main app
2. Navigate to the "Nearby" tab or try to add a stop with current location
3. You should see a permission dialog with your usage description
4. Grant "While Using the App" permission
5. The app should now be able to access your location

## Widget Location Access

For widgets to access location:
1. Main app must have location permission granted
2. Widget's Info.plist must have NSWidgetWantsLocation = true
3. App Group must be configured for data sharing
4. Widget must be in "automatic" mode to use location
