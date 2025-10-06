//
//  FilterView.swift
//  PantryChef
//
//  Created by Ethan on 5/10/2025.
//

import SwiftUI

struct FilterView: View {
    @AppStorage("diet") private var diet: String = "none"
    @AppStorage("intolerances") private var intolerancesCSV: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Diet", selection: $diet) {
                        Text("None").tag("none")
                        Text("Vegetarian").tag("vegetarian")
                        Text("Vegan").tag("vegan")
                        Text("Gluten-Free").tag("glutenFree")
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Dietary Preference")
                } footer: {
                    Text("Filter recipes based on your diet")
                }
                
                Section {
                    TextField("e.g., peanut, soy, dairy", text: $intolerancesCSV)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Intolerances")
                } footer: {
                    Text("Comma separated. Recipes with these ingredients will be excluded.")
                }
            }
            .navigationTitle("Filter Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FilterView()
}
