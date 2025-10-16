# 🎯 Quick Reference Card

## ⚡ 3-Minute Setup

```
1. Open Xcode project
2. Add App Group to BOTH targets: group.com.hrln.tripPlanner
3. Add location permissions to main app Info.plist
4. Build and run!
```

See `SETUP_CHECKLIST.md` for detailed steps.

---

## 📱 App Structure

```
┌─────────────────────┐
│   My Stops Tab      │  ← Add, view, manage stops
├─────────────────────┤
│   Nearby Tab        │  ← Auto-find nearest stop
├─────────────────────┤
│   Settings Tab      │  ← Permissions, data, stats
└─────────────────────┘
```

---

## 🔧 Key Files

### You Need to Configure:
- **App Group** in both targets
- **Info.plist** location permissions (main app)

### New Files Created:
```
Models/TransportStop.swift       ← Stop data model
Managers/LocationManager.swift   ← Location services
Managers/StopsManager.swift      ← Stop storage
Views/StopsListView.swift        ← Main stop list
Views/AddStopView.swift          ← Add new stops
Views/StopDetailView.swift       ← Stop details
Views/MapPickerView.swift        ← Map selection
NewContentView.swift             ← Main app UI
tripPlannerApp.swift             ← App entry
```

### Widget Files Updated:
```
AppIntent.swift                  ← Auto/manual modes
BusTrackerWidget.swift           ← Location support
SharedModels.swift               ← New shared models
Info.plist                       ← Location flag
```

---

## 🎬 Usage Flows

### Add a Stop
```
My Stops → + → Enter Details → Pick Location → Add Stop
```

### View Nearby
```
Nearby Tab → Select Type → See Nearest → View Departures
```

### Configure Widget
```
Long Press → Edit Widget → Choose Mode → Select Type → Done
```

---

## 🔑 Important Constants

```swift
App Group ID: "group.com.hrln.tripPlanner"
UserDefaults Key: "savedTransportStops"
Widget Update: Every 2 minutes
Location Filter: 50 meters
Timeline: 30 minutes ahead
```

---

## ✅ Must-Do Checklist

Before building:
- [ ] App Group added to tripPlanner target
- [ ] App Group added to BusTrackerWidgetExtension target
- [ ] Location permissions in main app Info.plist
- [ ] All new files in correct targets

Before testing:
- [ ] Build succeeds for both schemes
- [ ] No import errors
- [ ] Widget Info.plist has NSWidgetWantsLocation

Before releasing:
- [ ] Test on physical device
- [ ] Location permission flow works
- [ ] Can add/delete stops
- [ ] Widget shows in both modes
- [ ] Data syncs between app/widget

---

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Build errors | Check file target membership |
| No location permission | Check Info.plist keys |
| Widget not updating | Verify App Group matches |
| Can't add stops | Check network connection |
| Stops not syncing | Rebuild both targets |

See `COMPLETE_SUMMARY.md` → Troubleshooting section.

---

## 📚 Documentation Quick Links

| Need to... | Read... |
|------------|---------|
| Set up Xcode | `SETUP_CHECKLIST.md` |
| Understand features | `COMPLETE_SUMMARY.md` |
| Configure Info.plist | `INFO_PLIST_SETUP.md` |
| Learn architecture | `ARCHITECTURE.md` |
| Get started quickly | `README.md` |

---

## 💡 Pro Tips

1. **Testing**: Use "Load Sample Data" in Settings for quick testing
2. **Debugging**: Check Xcode console for error messages
3. **Widget**: Remove and re-add if not updating
4. **Location**: Always test on device, not just simulator
5. **Validation**: Invalid stop IDs will be rejected when adding

---

## 🎯 What Changed from v1.0

| Before | After |
|--------|-------|
| Single hardcoded stop | Multiple saved stops with GPS |
| No location services | Full location integration |
| Basic widget | Smart auto/manual widget modes |
| Simple list | Comprehensive tab-based UI |
| No map | Interactive map picker |
| No data sharing | App Group persistence |

---

## 📊 Key Metrics

- **Files Created**: 15+ new Swift files
- **Setup Time**: 5-10 minutes
- **Learning Curve**: Medium (SwiftUI knowledge helpful)
- **iOS Version**: 17.0+
- **Xcode Version**: 16.0+

---

## 🚀 Next Steps After Setup

1. Build and run the app
2. Grant location permission
3. Add your first stop (use a real stop ID)
4. Add the widget to home screen
5. Test automatic mode
6. Test manual mode
7. Add more stops as needed

---

## 🎨 SwiftUI Patterns Used

```swift
@Observable              → StopsManager
@ObservableObject        → LocationManager  
@Environment             → Dependency injection
@State                   → Local UI state
@Binding                 → Two-way data flow
async/await              → Network calls
Codable                  → JSON persistence
CLLocationManager        → Location services
```

---

## 📝 Remember

✅ App Group must match exactly in both targets  
✅ Location permissions required in main app Info.plist  
✅ Widget needs NSWidgetWantsLocation = true  
✅ All new files must be in correct targets  
✅ Test on real device for best location accuracy  

---

**Need help?** Start with `SETUP_CHECKLIST.md` and follow step-by-step! 🎯
