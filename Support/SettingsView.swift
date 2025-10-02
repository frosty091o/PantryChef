//
//  SettingsView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("diet") private var diet: String = "none"
    @AppStorage("intolerances") private var intolerancesCSV: String = ""
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    var body: some View {
        Form {
            Section("Diet") {
                Picker("Diet", selection: $diet) {
                    Text("None").tag("none")
                    Text("Vegetarian").tag("vegetarian")
                    Text("Vegan").tag("vegan")
                    Text("Gluten-Free").tag("glutenFree")
                }
                .pickerStyle(.segmented)
            }

            Section("Intolerances") {
                TextField("Comma separated (e.g., peanut, soy)", text: $intolerancesCSV)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Section("App") {
                Toggle("I’ve completed onboarding", isOn: $hasOnboarded)
            }
        }
        .navigationTitle("Settings")
    }
}
