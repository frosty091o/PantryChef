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
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationTitle("PantryChef")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
