//
//  MapPickerView.swift
//  tripPlanner
//
//  Created by GitHub Copilot on 16/10/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var coordinate: CLLocationCoordinate2D?
    let initialPosition: MapCameraPosition
    
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition
    
    init(coordinate: Binding<CLLocationCoordinate2D?>, initialPosition: MapCameraPosition) {
        self._coordinate = coordinate
        self.initialPosition = initialPosition
        _cameraPosition = State(wrappedValue: initialPosition)
        _selectedLocation = State(wrappedValue: coordinate.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition) {
                    if let location = selectedLocation {
                        Marker("Selected Location", systemImage: "mappin", coordinate: location)
                            .tint(.red)
                    }
                }
                .onTapGesture { location in
                    // Convert tap location to coordinates
                    // Note: For precise coordinate selection, we'll use the map's center
                }
                .onMapCameraChange { context in
                    // Update selected location based on map center
                    selectedLocation = context.region.center
                }
                
                // Crosshair in center
                VStack {
                    Spacer()
                    Image(systemName: "scope")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                        .shadow(color: .white, radius: 3)
                    Spacer()
                }
                .allowsHitTesting(false)
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        coordinate = selectedLocation
                        dismiss()
                    }
                    .disabled(selectedLocation == nil)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let location = selectedLocation {
                    VStack(spacing: 8) {
                        Text("Tap 'Done' to confirm this location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Latitude:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(location.latitude, specifier: "%.6f")")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Longitude:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(location.longitude, specifier: "%.6f")")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    MapPickerView(
        coordinate: .constant(CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)),
        initialPosition: .automatic
    )
}
