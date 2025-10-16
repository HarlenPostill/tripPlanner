//
//  AddStopView.swift
//  tripPlanner
//
//  Created by GitHub Copilot on 16/10/2025.
//

import SwiftUI
import MapKit

struct AddStopView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StopsManager.self) private var stopsManager
    @Environment(LocationManager.self) private var locationManager
    
    @State private var stopName: String = ""
    @State private var stopId: String = ""
    @State private var selectedStopType: StopType = .bus
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var showingMap = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isValidating = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Stop Information") {
                    TextField("Stop Name", text: $stopName)
                        .textContentType(.name)
                    
                    TextField("Stop ID", text: $stopId)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                    
                    Picker("Transport Type", selection: $selectedStopType) {
                        ForEach(StopType.allCases) { type in
                            Label(type.displayName, systemImage: type.systemImageName)
                                .tag(type)
                        }
                    }
                }
                
                Section("Location") {
                    if let coordinate = selectedCoordinate {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selected Location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Lat: \(coordinate.latitude, specifier: "%.6f")")
                                .font(.footnote)
                            Text("Lng: \(coordinate.longitude, specifier: "%.6f")")
                                .font(.footnote)
                            
                            Button("Change Location") {
                                showingMap = true
                            }
                        }
                    } else {
                        Button {
                            showingMap = true
                        } label: {
                            Label("Select Location on Map", systemImage: "map")
                        }
                        
                        if let userLocation = locationManager.location {
                            Button {
                                selectedCoordinate = userLocation.coordinate
                            } label: {
                                Label("Use Current Location", systemImage: "location.fill")
                            }
                        }
                    }
                }
                
                Section {
                    Button("Add Stop") {
                        addStop()
                    }
                    .disabled(!isFormValid || isValidating)
                    .frame(maxWidth: .infinity)
                    
                    if isValidating {
                        ProgressView("Validating stop...")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Add Stop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingMap) {
                MapPickerView(
                    coordinate: $selectedCoordinate,
                    initialPosition: initialMapPosition
                )
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !stopName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !stopId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedCoordinate != nil
    }
    
    private var initialMapPosition: MapCameraPosition {
        if let userLocation = locationManager.location {
            return .region(MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            // Default to Sydney
            return .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    private func addStop() {
        guard let coordinate = selectedCoordinate else {
            errorMessage = "Please select a location for the stop"
            showingError = true
            return
        }
        
        let trimmedName = stopName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedId = stopId.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if stop ID is unique
        if !stopsManager.isStopIdUnique(trimmedId) {
            errorMessage = "A stop with this ID already exists"
            showingError = true
            return
        }
        
        // Optionally validate the stop ID against the API
        isValidating = true
        
        Task {
            do {
                // Try to fetch data for this stop to validate it exists
                _ = try await TransportService.shared.fetchDepartures(
                    for: trimmedId,
                    transportType: selectedStopType == .bus ? .bus : .lightRail
                )
                
                // If successful, create and save the stop
                let newStop = TransportStop(
                    name: trimmedName,
                    stopId: trimmedId,
                    stopType: selectedStopType,
                    coordinate: coordinate
                )
                
                await MainActor.run {
                    stopsManager.addStop(newStop)
                    isValidating = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isValidating = false
                    errorMessage = "Unable to validate stop ID. Please check and try again.\n\(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    AddStopView()
        .environment(StopsManager.shared)
        .environment(LocationManager())
}
