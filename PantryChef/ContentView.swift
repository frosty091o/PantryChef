//
//  ContentView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var locationManager = LocationManager()
    @State private var showStoreSearch = false
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var showOnboarding = false
    @State private var hasCheckedOnboarding = false // Track if we've checked already

    var body: some View {
        NavigationStack {
            TabView {
                PantryView(context: viewContext)
                    .tabItem { Label("Pantry", systemImage: "tray") }

                DiscoverView()
                    .tabItem { Label("Discover", systemImage: "magnifyingglass") }

                FavouritesView()
                    .tabItem { Label("Favourites", systemImage: "heart") }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // Quick access to find stores - useful for shopping
                    Button {
                        locationManager.request()
                        showStoreSearch = true
                    } label: {
                        Label("Find Stores", systemImage: "map")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationTitle("PantryChef")
            .sheet(isPresented: $showStoreSearch) {
                NearbyStoresView(userCoordinate: locationManager.coordinate, searchQuery: "supermarket")
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView()
            }
            .onChange(of: hasOnboarded) { newValue in
                if newValue {
                    showOnboarding = false
                }
            }
            .task {
                // Only check onboarding once on actual app launch
                if !hasCheckedOnboarding {
                    hasCheckedOnboarding = true
                    if !hasOnboarded {
                        // Small delay to ensure UI is ready
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        showOnboarding = true
                    }
                }
                
                // Request location permission on app start
                locationManager.request()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

