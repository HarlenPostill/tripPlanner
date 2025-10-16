//
//  StopsListView.swift
//  tripPlanner
//
//  Created by GitHub Copilot on 16/10/2025.
//

import SwiftUI
import CoreLocation

struct StopsListView: View {
    @Environment(StopsManager.self) private var stopsManager
    @Environment(LocationManager.self) private var locationManager
    @State private var showingAddStop = false
    @State private var selectedStopType: StopType = .bus
    
    var body: some View {
        NavigationStack {
            List {
                if stopsManager.stops.isEmpty {
                    ContentUnavailableView(
                        "No Stops Saved",
                        systemImage: "mappin.slash",
                        description: Text("Add transport stops to track their departures")
                    )
                } else {
                    // Bus Stops Section
                    if !stopsManager.busStops.isEmpty {
                        Section {
                            ForEach(sortedStops(stopsManager.busStops)) { stop in
                                NavigationLink(destination: StopDetailView(stop: stop)) {
                                    StopRow(stop: stop, currentLocation: locationManager.location)
                                }
                            }
                            .onDelete { indexSet in
                                deleteStops(at: indexSet, from: stopsManager.busStops)
                            }
                        } header: {
                            HStack {
                                Image(systemName: "bus")
                                Text("Bus Stops")
                            }
                        }
                    }
                    
                    // Light Rail Stops Section
                    if !stopsManager.lightRailStops.isEmpty {
                        Section {
                            ForEach(sortedStops(stopsManager.lightRailStops)) { stop in
                                NavigationLink(destination: StopDetailView(stop: stop)) {
                                    StopRow(stop: stop, currentLocation: locationManager.location)
                                }
                            }
                            .onDelete { indexSet in
                                deleteStops(at: indexSet, from: stopsManager.lightRailStops)
                            }
                        } header: {
                            HStack {
                                Image(systemName: "tram")
                                Text("Light Rail Stops")
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Stops")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddStop = true
                    } label: {
                        Label("Add Stop", systemImage: "plus")
                    }
                }
                
                if !stopsManager.stops.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAddStop) {
                AddStopView()
            }
        }
    }
    
    private func sortedStops(_ stops: [TransportStop]) -> [TransportStop] {
        guard let location = locationManager.location else {
            return stops.sorted { $0.name < $1.name }
        }
        
        return stops.sorted { stop1, stop2 in
            stop1.distance(from: location) < stop2.distance(from: location)
        }
    }
    
    private func deleteStops(at offsets: IndexSet, from stops: [TransportStop]) {
        for index in offsets {
            stopsManager.deleteStop(stops[index])
        }
    }
}

// MARK: - Stop Row
struct StopRow: View {
    let stop: TransportStop
    let currentLocation: CLLocation?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stop.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Label(stop.stopId, systemImage: "number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let location = currentLocation {
                        Label(stop.formattedDistance(from: location), systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: stop.stopType.systemImageName)
                .foregroundColor(.accentColor)
                .font(.title3)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        StopsListView()
            .environment(StopsManager.shared)
            .environment(LocationManager())
    }
}
