//
//  NewContentView.swift
//  tripPlanner
//
//  Created by GitHub Copilot on 16/10/2025.
//

import SwiftUI
import CoreLocation

struct NewContentView: View {
    @State private var stopsManager = StopsManager.shared
    @State private var locationManager = LocationManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // My Stops Tab
            StopsListView()
                .tabItem {
                    Label("My Stops", systemImage: "mappin.and.ellipse")
                }
                .tag(0)
            
            // Nearby Tab (shows all departures from nearest stop)
            NearbyDeparturesView()
                .tabItem {
                    Label("Nearby", systemImage: "location.fill")
                }
                .tag(1)
            
            // Settings/Info Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
        .environment(stopsManager)
        .environment(locationManager)
        .onAppear {
            // Update location manager with saved stops
            locationManager.updateStops(stopsManager.stops)
            
            // Request location permission if needed
            if !locationManager.isAuthorized {
                locationManager.requestPermission()
            }
        }
        .onChange(of: stopsManager.stops) { _, newStops in
            locationManager.updateStops(newStops)
        }
    }
}

// MARK: - Nearby Departures View
struct NearbyDeparturesView: View {
    @Environment(StopsManager.self) private var stopsManager
    @Environment(LocationManager.self) private var locationManager
    @State private var selectedTransportType: StopType = .bus
    @State private var departures: [StopEvent] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var nearestStop: TransportStop?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Transport type picker
                Picker("Transport Type", selection: $selectedTransportType) {
                    ForEach(StopType.allCases) { type in
                        Label(type.displayName, systemImage: type.systemImageName)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedTransportType) { _, _ in
                    loadNearestDepartures()
                }
                
                if locationManager.isAuthorized {
                    if let error = errorMessage {
                        ContentUnavailableView(
                            "Error",
                            systemImage: "exclamationmark.triangle",
                            description: Text(error)
                        )
                    } else if isLoading {
                        VStack {
                            Spacer()
                            ProgressView("Finding nearest stop...")
                            Spacer()
                        }
                    } else if let stop = nearestStop {
                        List {
                            Section {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(stop.name)
                                            .font(.headline)
                                        
                                        if let location = locationManager.location {
                                            Text(stop.formattedDistance(from: location))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: StopDetailView(stop: stop)) {
                                        EmptyView()
                                    }
                                }
                            } header: {
                                Text("Nearest \(selectedTransportType.displayName) Stop")
                            }
                            
                            Section("Next Departures") {
                                if departures.isEmpty {
                                    Text("No departures available")
                                        .foregroundColor(.secondary)
                                } else {
                                    ForEach(departures.prefix(10)) { departure in
                                        TransportDepartureRow(departure: departure)
                                    }
                                }
                            }
                        }
                    } else {
                        ContentUnavailableView(
                            "No Stops Nearby",
                            systemImage: "mappin.slash",
                            description: Text("Add \(selectedTransportType.displayName.lowercased()) stops to track their departures")
                        )
                    }
                } else {
                    ContentUnavailableView(
                        "Location Access Required",
                        systemImage: "location.slash",
                        description: Text("Please enable location access to see nearby departures")
                    )
                    .overlay(alignment: .bottom) {
                        Button("Enable Location") {
                            locationManager.requestPermission()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
            }
            .navigationTitle("Nearby Departures")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        loadNearestDepartures()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                if locationManager.isAuthorized {
                    locationManager.startUpdatingLocation()
                    loadNearestDepartures()
                }
            }
            .onChange(of: locationManager.isAuthorized) { _, authorized in
                if authorized {
                    locationManager.startUpdatingLocation()
                    loadNearestDepartures()
                }
            }
        }
    }
    
    private func loadNearestDepartures() {
        guard locationManager.isAuthorized else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            // Wait a moment for location to update
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            guard let nearest = locationManager.getNearestStop(of: selectedTransportType) else {
                await MainActor.run {
                    nearestStop = nil
                    departures = []
                    isLoading = false
                }
                return
            }
            
            do {
                let allDepartures = try await TransportService.shared.fetchDepartures(
                    for: nearest.stopId,
                    transportType: selectedTransportType == .bus ? .bus : .lightRail
                )
                
                await MainActor.run {
                    self.nearestStop = nearest
                    self.departures = allDepartures
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.nearestStop = nearest
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(StopsManager.self) private var stopsManager
    @Environment(LocationManager.self) private var locationManager
    @State private var showingClearConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Location Access")
                        Spacer()
                        if locationManager.isAuthorized {
                            Label("Enabled", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Label("Disabled", systemImage: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    
                    if !locationManager.isAuthorized {
                        Button("Request Location Access") {
                            locationManager.requestPermission()
                        }
                    }
                } header: {
                    Text("Permissions")
                } footer: {
                    Text("Location access is required for automatic nearest stop selection in widgets.")
                }
                
                Section {
                    HStack {
                        Text("Saved Stops")
                        Spacer()
                        Text("\(stopsManager.stops.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Bus Stops")
                        Spacer()
                        Text("\(stopsManager.busStops.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Light Rail Stops")
                        Spacer()
                        Text("\(stopsManager.lightRailStops.count)")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Statistics")
                }
                
                Section {
                    Button("Load Sample Data") {
                        stopsManager.loadSampleData()
                    }
                    
                    Button("Clear All Stops", role: .destructive) {
                        showingClearConfirmation = true
                    }
                } header: {
                    Text("Data Management")
                }
                
                Section {
                    HStack {
                        Text("App Group")
                        Spacer()
                        Text("group.com.hrln.tripPlanner")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Information")
                } footer: {
                    Text("This app uses an App Group to share data between the app and widgets.")
                }
            }
            .navigationTitle("Settings")
            .alert("Clear All Stops?", isPresented: $showingClearConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    stopsManager.clearAllStops()
                }
            } message: {
                Text("This will remove all saved stops. This action cannot be undone.")
            }
        }
    }
}

#Preview("Main") {
    NewContentView()
}

#Preview("Nearby") {
    NearbyDeparturesView()
        .environment(StopsManager.shared)
        .environment(LocationManager())
}

#Preview("Settings") {
    SettingsView()
        .environment(StopsManager.shared)
        .environment(LocationManager())
}
