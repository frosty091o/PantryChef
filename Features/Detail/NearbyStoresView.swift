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

    @State private var results: [MKMapItem] = []
    @State private var isSearching = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Group {
                if isSearching {
                    ProgressView("Searching supermarkets…")
                } else if let error {
                    VStack(spacing: 8) {
                        Text(error).foregroundStyle(.red)
                        Button("Try again") { Task { await search() } }
                            .buttonStyle(.borderedProminent)
                    }
                } else if results.isEmpty {
                    ContentUnavailableView("No nearby supermarkets",
                                           systemImage: "mappin.slash",
                                           description: Text("Try again in a different area."))
                } else {
                    List(results, id: \.self) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name ?? "Supermarket").font(.headline)
                            if let a = item.placemark.title {
                                Text(a).font(.subheadline).foregroundStyle(.secondary)
                            }
                            Button("Open in Maps") {
                                item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                            }
                            .buttonStyle(.bordered)
                            .padding(.top, 4)
                        }
                    }
                }
            }
            .navigationTitle("Nearby Supermarkets")
            .task { await search() }
        }
    }

    private func searchRadiusRegion() -> MKCoordinateRegion? {
        guard let c = userCoordinate else { return nil }
        return MKCoordinateRegion(center: c, latitudinalMeters: 5000, longitudinalMeters: 5000)
    }

    private func searchText() -> String { "supermarket" }

    private func searchRequest() -> MKLocalSearch.Request? {
        guard let region = searchRadiusRegion() else { return nil }
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = searchText()
        req.region = region
        return req
    }

    private func search() async {
        isSearching = true; error = nil; results = []
        guard let req = searchRequest() else {
            error = "Location unavailable. Allow location access in Settings."
            isSearching = false
            return
        }
        do {
            let response = try await MKLocalSearch(request: req).start()
            results = response.mapItems
        } catch {
            self.error = "Search failed. Please try again."
        }
        isSearching = false
    }
}
