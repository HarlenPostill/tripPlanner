import SwiftUI

// MARK: - Main View
struct ContentView: View {
    @StateObject private var viewModel = BusViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Loading departures...")
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                            .font(.largeTitle)
                        Text("Error")
                            .font(.headline)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                } else if viewModel.departures.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "bus")
                            .foregroundColor(.secondary)
                            .font(.largeTitle)
                        Text("No departures")
                            .font(.headline)
                        Text("Try refreshing to check for updates")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(viewModel.departures) { departure in
                        BusDepartureRow(departure: departure)
                    }
                    .listStyle(.plain)
                }
                
                Button(action: {
                    viewModel.fetchDepartures()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(viewModel.isLoading)
            }
            .navigationTitle("Bus Departures")
            .onAppear {
                viewModel.fetchDepartures()
            }
        }
    }
}

// MARK: - Bus Departure Row
struct BusDepartureRow: View {
    let departure: StopEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Bus number badge
                Text(departure.transportation.number)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: departure.transportation.colour.foreground))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: departure.transportation.colour.background))
                    .cornerRadius(6)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(departure.transportation.destination.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if !departure.transportation.description.isEmpty {
                        Text(departure.transportation.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(departure.timeUntilDeparture())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor())
                    
                    if let delayText = departure.delayStatus() {
                        Text(delayText)
                            .font(.caption)
                            .foregroundColor(statusColor())
                            .fontWeight(.semibold)
                    }
                }
            }
            
            if departure.isCancelled {
                Text("CANCELLED")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func statusColor() -> Color {
        if departure.isCancelled {
            return .red
        }
        
        if departure.departureStatus?.lowercased() == "late" {
            return .orange
        }
        
        return .primary
    }
}

// MARK: - View Model
// MARK: - View Model
class BusViewModel: ObservableObject {
    @Published var departures: [StopEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let stopId = "G203519"
    
    func fetchDepartures() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let allDepartures = try await BusService.shared.fetchDepartures(for: stopId)
                
                DispatchQueue.main.async {
                    self.departures = Array(allDepartures.prefix(10)) // Show up to 10 departures
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Entry Point
@main
struct BusTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
