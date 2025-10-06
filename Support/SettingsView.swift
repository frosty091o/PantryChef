//
//  SettingsView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    var body: some View {
        Form {
            Section("Analytics") {
                NavigationLink(destination: AnalyticsView()) {
                    Label("View Analytics", systemImage: "chart.bar")
                }
            }

            Section("App") {
                Toggle("I've completed onboarding", isOn: $hasOnboarded)
            }
            
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("About")
            } footer: {
                Text("PantryChef - Find recipes based on your ingredients")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
