//
//  SettingsView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var prefs = AppPreferences.shared

    var body: some View {
        Form {
            Section("Diet") {
                Picker("Diet", selection: $prefs.diet) {
                    Text("None").tag("none")
                    Text("Vegetarian").tag("vegetarian")
                    Text("Vegan").tag("vegan")
                    Text("Gluten-Free").tag("glutenFree")
                }
                .pickerStyle(.segmented)
            }

            Section("Intolerances") {
                TextField("Comma separated (e.g., peanut, soy)", text: $prefs.intolerancesCSV)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Section("App") {
                Toggle("I’ve completed onboarding", isOn: $prefs.hasOnboarded)
            }
        }
        .navigationTitle("Settings")
    }
}
