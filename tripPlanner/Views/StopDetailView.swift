//
//  StopDetailView.swift
//  tripPlanner
//
//  Created by GitHub Copilot on 16/10/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct StopDetailView: View {
    let stop: TransportStop
    
    @State private var departures: [StopEvent] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(LocationManager.self) private var locationManager
    @State private var mapRegion: MKCoordinateRegion
    
    init(stop: TransportStop) {
        self.stop = stop
        _mapRegion = State(wrappedValue: MKCoordinateRegion(
            center: stop.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label(stop.stopType.displayName, systemImage: stop.stopType.systemImageName)
                            .font(.headline)
                        
                        Spacer()
                        
                        if let location = locationManager.location {
                            Label(stop.formattedDistance(from: location), systemImage: "location.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Stop ID:")
                            .foregroundColor(.secondary)
                        Text(stop.stopId)
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    
                    // Map preview
                    Map(position: .constant(.region(mapRegion))) {
                        Marker(stop.name, systemImage: stop.stopType.systemImageName, coordinate: stop.coordinate)
                            .tint(.foreground)
                    }
                    .frame(height: 150)
                    .cornerRadius(10)
                    .allowsHitTesting(false)
                }
                .padding(.vertical, 8)
            } header: {
                Text("Stop Information")
            }
            
            Section {
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Loading departures...")
                        Spacer()
                    }
                    .padding()
                } else if let error = errorMessage {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                            .font(.largeTitle)
                        Text("Error")
                            .font(.headline)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else if departures.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: stop.stopType.systemImageName)
                            .foregroundColor(.secondary)
                            .font(.largeTitle)
                        Text("No departures")
                            .font(.headline)
                        Text("Try refreshing to check for updates")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(departures.prefix(10)) { departure in
                        TransportDepartureRow(departure: departure)
                    }
                }
            } header: {
                HStack {
                    Text("Next Departures")
                    Spacer()
                    Button {
                        fetchDepartures()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                    }
                    .disabled(isLoading)
                }
            }
        }
        .navigationTitle(stop.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchDepartures()
        }
    }
    
    private func fetchDepartures() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let allDepartures = try await TransportService.shared.fetchDepartures(
                    for: stop.stopId,
                    transportType: stop.stopType == .bus ? .bus : .lightRail
                )
                
                await MainActor.run {
                    self.departures = allDepartures
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StopDetailView(stop: TransportStop.sampleBusStop)
            .environment(LocationManager())
    }
}
