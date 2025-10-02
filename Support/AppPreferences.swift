//
//  AppPreferences.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI

/// Global app settings backed by UserDefaults.
/// Usage: AppPreferences.shared or inject as an EnvironmentObject.
final class AppPreferences: ObservableObject {
    static let shared = AppPreferences()

    // First-run flag
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false

    // Diet filter: "none" | "vegetarian" | "vegan" | "glutenFree"
    @AppStorage("diet") var diet: String = "none"

    // Comma-separated intolerances: e.g. "peanut,soy,lactose"
    @AppStorage("intolerances") var intolerancesCSV: String = ""

    // Convenience computed property
    var intolerances: [String] {
        get { intolerancesCSV.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty } }
        set { intolerancesCSV = newValue.joined(separator: ",") }
    }
}
