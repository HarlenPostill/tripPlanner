# Setup Checklist - Complete These Steps in Order

## ⚠️ MUST DO - Xcode Configuration

### ✅ Step 1: Configure App Groups (5 minutes)

**For tripPlanner target:**
1. [ ] Open Xcode project
2. [ ] Select **tripPlanner** target in project navigator
3. [ ] Click **Signing & Capabilities** tab
4. [ ] Click **+ Capability** button (top left)
5. [ ] Select **App Groups** from the list
6. [ ] Click **+** in the App Groups section
7. [ ] Enter: `group.com.hrln.tripPlanner`
8. [ ] Ensure the checkbox next to it is **checked**

**For BusTrackerWidgetExtension target:**
9. [ ] Select **BusTrackerWidgetExtension** target
10. [ ] Click **Signing & Capabilities** tab
11. [ ] Click **+ Capability** button
12. [ ] Select **App Groups**
13. [ ] Click **+** in the App Groups section
14. [ ] Enter: `group.com.hrln.tripPlanner` (must match exactly!)
15. [ ] Ensure checkbox is **checked**

### ✅ Step 2: Add Location Permissions to Main App (3 minutes)

**Option A - Using Xcode UI (Recommended):**
1. [ ] Select **tripPlanner** target
2. [ ] Click **Info** tab
3. [ ] Click **+** button to add new row
4. [ ] Select: `Privacy - Location When In Use Usage Description`
5. [ ] Set value: `This app uses your location to find the nearest transport stops and show real-time departure information.`
6. [ ] Click **+** to add another row
7. [ ] Select: `Privacy - Location Always and When In Use Usage Description`
8. [ ] Set value: `This app uses your location to keep widgets updated with the nearest transport stop departures.`

**Option B - Edit Info.plist directly (if you have one):**
1. [ ] Find Info.plist in tripPlanner folder
2. [ ] Open it
3. [ ] Add the XML keys shown in `INFO_PLIST_SETUP.md`

### ✅ Step 3: Verify File Target Membership (5 minutes)

**Check these files are in tripPlanner target:**
1. [ ] Models/TransportStop.swift
2. [ ] Managers/LocationManager.swift
3. [ ] Managers/StopsManager.swift
4. [ ] Views/StopsListView.swift
5. [ ] Views/AddStopView.swift
6. [ ] Views/StopDetailView.swift
7. [ ] Views/MapPickerView.swift
8. [ ] NewContentView.swift
9. [ ] tripPlannerApp.swift

**Check these files are in BusTrackerWidgetExtension target:**
10. [ ] SharedModels.swift
11. [ ] BusTrackerWidget.swift (should already be there)
12. [ ] AppIntent.swift (should already be there)

**How to check:**
- Click on each file in Project Navigator
- Open File Inspector (right panel, or Cmd+Option+1)
- Look at "Target Membership" section
- Check the appropriate target box

### ✅ Step 4: Update App Entry Point (2 minutes)

Choose one option:

**Option A - Use new file:**
1. [ ] Delete or comment out the `@main` struct in ContentView.swift (if it has one)
2. [ ] The new `tripPlannerApp.swift` file will be your app entry point
3. [ ] Make sure it's in the tripPlanner target

**Option B - Update existing file:**
1. [ ] Find your current `@main struct` (likely in ContentView.swift or similar)
2. [ ] Replace its `body` to use `NewContentView()` instead of `ContentView()`

### ✅ Step 5: Build & Verify (2 minutes)

1. [ ] Select a physical device or simulator
2. [ ] Build the **tripPlanner** scheme (Cmd+B)
3. [ ] Check for any build errors
4. [ ] Fix missing imports or target membership issues
5. [ ] Build the **BusTrackerWidgetExtension** scheme
6. [ ] Verify both build successfully

## 🎯 Testing Checklist

### Test on Device (15 minutes)

**First Launch:**
1. [ ] Build and run on device
2. [ ] App should show 3 tabs: My Stops, Nearby, Settings
3. [ ] Tap "Nearby" tab
4. [ ] Location permission dialog should appear
5. [ ] Grant "While Using the App" permission
6. [ ] App should show "No Stops Nearby" (if none added yet)

**Add Your First Stop:**
7. [ ] Go to "My Stops" tab
8. [ ] Tap **+** button
9. [ ] Enter:
   - Name: `Test Bus Stop`
   - Stop ID: `G203519` (or any valid bus stop ID you know)
   - Type: Bus
10. [ ] Tap "Use Current Location" or "Select Location on Map"
11. [ ] If using map: Position crosshair, tap "Done"
12. [ ] Tap "Add Stop"
13. [ ] Wait for validation (should succeed)
14. [ ] Stop should appear in "My Stops" list

**Test Stop Details:**
15. [ ] Tap on the stop you just added
16. [ ] Should see stop details with map
17. [ ] Should see "Loading departures..." then actual departures
18. [ ] Verify departure times look correct
19. [ ] Tap refresh button - should reload

**Test Nearby Tab:**
20. [ ] Go back to "Nearby" tab
21. [ ] Select "Bus" at the top
22. [ ] Should show your added stop (if it's the nearest)
23. [ ] Should display departures

**Test Widget:**
24. [ ] Go to home screen
25. [ ] Add a small Transport Tracker widget
26. [ ] Long press widget → "Edit Widget"
27. [ ] Try **Automatic** mode with Bus
28. [ ] Widget should show nearest bus stop
29. [ ] Edit again → Try **Manual** mode
30. [ ] Enter stop ID `G203519`
31. [ ] Widget should show that specific stop

**Test Settings:**
32. [ ] Go to Settings tab
33. [ ] Check "Location Access" shows "Enabled"
34. [ ] Check "Saved Stops" shows count
35. [ ] Try "Load Sample Data"
36. [ ] Go to My Stops - should see sample stops
37. [ ] Back to Settings → "Clear All Stops"
38. [ ] Confirm - stops should be cleared

## ✅ Final Verification

**App Functionality:**
- [ ] Can add stops with location
- [ ] Stops show distance from current location
- [ ] Can view live departures for any stop
- [ ] Can delete stops
- [ ] Map picker works smoothly
- [ ] Nearby tab shows correct nearest stop
- [ ] Both bus and light rail stops work

**Widget Functionality:**
- [ ] Widget displays in automatic mode
- [ ] Widget displays in manual mode
- [ ] Widget shows departure times
- [ ] Widget updates every 2 minutes
- [ ] Widget configuration persists

**Data Sharing:**
- [ ] Stops added in app appear in widget
- [ ] Changes sync between app and widget
- [ ] Works after app is force-quit
- [ ] Works after device restart

**Permissions & Privacy:**
- [ ] Location permission dialog is clear
- [ ] App works without location (manual mode)
- [ ] Widget respects location settings
- [ ] No crashes when location denied

## 🎉 You're Done!

Once all checkboxes are checked, your location-based transport tracking app is fully implemented and working!

## 📝 Notes

**If something doesn't work:**
1. Check `COMPLETE_SUMMARY.md` for troubleshooting
2. Verify App Group identifiers match exactly
3. Rebuild both targets
4. Check Xcode console for error messages
5. Ensure all files are in correct targets

**Common Issues:**
- Build error → Check file target membership
- No location permission → Check Info.plist keys
- Widget not updating → Check App Group configuration
- Can't add stops → Check network connection and API key

**Getting Help:**
- Review code comments in source files
- Check `IMPLEMENTATION_GUIDE.md` for architecture
- See `INFO_PLIST_SETUP.md` for detailed Xcode steps
