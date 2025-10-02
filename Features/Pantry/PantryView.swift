//
//  PantryView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI

struct PantryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Pantry").font(.title2).bold()
            Text("Add ingredients here (coming soon).")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
