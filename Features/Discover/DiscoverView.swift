//
//  DiscoverView.swift
//  PantryChef
//
//  Created by Ethan on 3/10/2025.
//

import SwiftUI

struct DiscoverView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Discover").font(.title2).bold()
            Text("Find recipes from your pantry (coming soon).")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
