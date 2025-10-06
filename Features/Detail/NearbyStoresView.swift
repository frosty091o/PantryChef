//
//  NearbyStoresView.swift
//  PantryChef
//
//  Created by Ethan on 4/10/2025.
//

import SwiftUI
import MapKit

struct NearbyStoresView: View {
    let userCoordinate: CLLocationCoordinate2D?
    let searchQuery: String // What to search for

    @State private var results: [MKMapItem] = []
    @State private var isSearching = true
    @State private var error: String?
    @State private var mapCameraPosition: MapCameraPosition

    init(userCoordinate: CLLocationCoordinate2D?, searchQuery: String = "supermarket") {
        self.userCoordinate = userCoordinate
        self.searchQuery = searchQuery
        // Initialize map region
        if let coord = userCoordinate {
            _mapCameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )))
        } else {
            _mapCameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )))
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Simple map at top - shows user location and store pins
                Map(position: $mapCameraPosition) {
                    // User location
                    if let coord = userCoordinate {
                        Annotation("You", coordinate: coord) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 12, height: 12)
                        }
                    }

                    // Store markers
                    ForEach(results, id: \.self) { item in
                        let coord = item.location.coordinate
                        Marker(item.name ?? searchQuery.capitalized,
                               coordinate: coord)
                            .tint(.red)
                    }
                }
                .frame(height: 250)
                
                // Store list
                if isSearching {
                    ProgressView("Searching \(searchQuery)s…")
                        .padding()
                    Spacer()
                } else if let error {
                    VStack(spacing: 8) {
                        Text(error).foregroundStyle(.red)
                        Button("Try again") { Task { await search() } }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else if results.isEmpty {
                    ContentUnavailableView("No nearby \(searchQuery)s found",
                                           systemImage: "mappin.slash",
                                           description: Text("Try again in a different area."))
                } else {
                    List(results, id: \.self) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name ?? searchQuery.capitalized).font(.headline)
                            
                            // Removed address line as instructed
                            
                            // Calculate distance (simple version)
                            if let userCoord = userCoordinate {
                                let storeCoord = item.location.coordinate
                                let distance = calculateDistance(from: userCoord, to: storeCoord)
                                Text(String(format: "%.1f km away", distance))
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                            
                            HStack(spacing: 8) {
                                Button("Directions") {
                                    item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                                }
                                .buttonStyle(.bordered)
                                
                                if let phone = item.phoneNumber {
                                    Button("Call") {
                                        if let url = URL(string: "tel://\(phone)") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Nearby \(searchQuery.capitalized)s")
            .task { await search() }
        }
    }

    func search() async {
        isSearching = true
        error = nil
        results = []
        
        guard let coord = userCoordinate else {
            error = "Location unavailable. Allow location access in Settings."
            isSearching = false
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        request.region = MKCoordinateRegion(center: coord, latitudinalMeters: 5000, longitudinalMeters: 5000)
        
        do {
            let response = try await MKLocalSearch(request: request).start()
            results = response.mapItems
        } catch {
            self.error = "Search failed. Please try again."
        }
        
        isSearching = false
    }
    
    // Simple distance calculation - found this formula online
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLoc = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLoc = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLoc.distance(from: toLoc) / 1000 // convert to km
    }
}

#Preview {
    NearbyStoresView(userCoordinate: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093), searchQuery: "supermarket")
}
