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
    @EnvironmentObject private var prefs: AppPreferences
    @State private var showOnboarding = false

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
        }
        .task {
            // Request location permission on app start
            locationManager.request()
            if !prefs.hasOnboarded {
                showOnboarding = true
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView {
                prefs.hasOnboarded = true
                showOnboarding = false
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppPreferences.shared)
}

private struct OnboardingView: View {
    let dismiss: () -> Void
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Welcome to PantryChef")
                    .font(.title).bold()
                Text("Add your pantry items, discover recipes, and find nearby supermarkets for anything you’re missing.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Get started") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Onboarding")
        }
    }
}
