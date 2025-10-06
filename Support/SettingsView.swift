//
//  SettingsView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    @Environment(\.managedObjectContext) private var context
    @State private var showClearAlert = false
    @State private var showResetPantryAlert = false
    @State private var isSyncing = false
    @State private var lastSyncTime: Date?

    var body: some View {
        Form {
            Section("Data") {
                NavigationLink(destination: AnalyticsView()) {
                    Label("View Analytics", systemImage: "chart.bar")
                }
                
                Button(role: .destructive) {
                    showClearAlert = true
                } label: {
                    Label("Clear Search History", systemImage: "trash")
                }
                
                Button(role: .destructive) {
                    showResetPantryAlert = true
                } label: {
                    Label("Reset Pantry", systemImage: "trash.fill")
                }
            }
            
            Section {
                Button {
                    syncNow()
                } label: {
                    HStack {
                        Label("Sync Now", systemImage: "arrow.triangle.2.circlepath")
                        Spacer()
                        if isSyncing {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                }
                .disabled(isSyncing)
                
                if let lastSync = lastSyncTime {
                    HStack {
                        Text("Last Synced")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(lastSync, style: .relative)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            } header: {
                Text("Cloud Sync")
            } footer: {
                Text("Your pantry and favorites are automatically synced to Firebase.")
            }
            
            Section {
                // Note: These features demonstrate @AppStorage (UserDefaults wrapper)
                // Values are saved but the actual features aren't fully implemented yet
                // Future: notificationsEnabled would schedule local notifications
                
                Toggle(isOn: $notificationsEnabled) {
                    HStack {
                        Label("Recipe Reminders", systemImage: "bell")
                        Spacer()
                        Text("Coming Soon")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                Toggle(isOn: $hasOnboarded) {
                    Label("Skip Onboarding Tutorial", systemImage: "book.closed")
                }
            } header: {
                Text("Development Features")
            } footer: {
                Text("Recipe Reminders is a placeholder for UserDefaults demo. Toggle 'Skip Onboarding' OFF to see the tutorial every time you open the app (useful for testing).")
                    .font(.caption)
            }

            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Developer")
                    Spacer()
                    Text("Ethan")
                        .foregroundStyle(.secondary)
                }
                
                Link(destination: URL(string: "https://spoonacular.com/food-api")!) {
                    HStack {
                        Text("Recipe API")
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                            .foregroundStyle(.blue)
                    }
                }
            } header: {
                Text("About")
            } footer: {
                Text("PantryChef helps you find recipes based on ingredients you already have. Data synced with Firebase.")
                    .font(.caption)
            }
        }
        .navigationTitle("Settings")
        .alert("Clear Search History", isPresented: $showClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                RecipeHistoryDB.shared.clearSearchHistory()
            }
        } message: {
            Text("This will delete all your search history and analytics data.")
        }
        .alert("Reset Pantry", isPresented: $showResetPantryAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetPantry()
            }
        } message: {
            Text("This will delete all items in your pantry. This cannot be undone.")
        }
    }
    
    private func syncNow() {
        isSyncing = true
        
        // Sync pantry
        FirestoreSync.shared.syncPantryItems(context: context) { result in
            // Sync favorites
            FirestoreSync.shared.syncFavourites(context: context) { _ in
                Task { @MainActor in
                    isSyncing = false
                    lastSyncTime = Date()
                }
            }
        }
    }
    
    private func resetPantry() {
        // Get all pantry items
        let fetchRequest = PantryItem.fetchRequest()
        
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                context.delete(item)
            }
            try context.save()
            print("Pantry reset successfully")
        } catch {
            print("Failed to reset pantry: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
